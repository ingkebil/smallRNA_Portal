#!usr/bin/perl
package GFF::Ath2sRNA;

use strict;
use warnings;
use Smart::Comments;
use Data::Dumper;
use GFF q/:GFF_SLOTS/;
use GFF::Parser;
use DBI;

# only run when modulino is used as a script and not a module
&run() unless caller;


=head1 
public static void main string args ;)
=cut
sub run {
    open F, '<', $ARGV[0] or die "Usage: $0 gfffile\n";
    my @lines = <F>;
    close F;

    my $ath2srna = __PACKAGE__->new;
    $ath2srna->run_parser(\@lines);

    print @{ $ath2srna->make_SQL };
}

sub new {
    my $inv = shift;
    my $class = ref $inv || $inv;

    my $gff = new GFF::Parser();
    my $dbh = DBI->connect('dbi:mysql:database=ssdb_nostruct', 'kebil', 'kebil') or die "Could not connect to DB\n";

    my $self = {
        parser => $gff,
        dbh    => $dbh,
        # structure is we want to get is something like this, which litterally translates to the DB scheme
        # { acc_nr.model_nr => { strand, chr, type, seq, start, stop, struct, coords => [{ start, stop, type => 5', 3', cds, '' }] } }
        genes   => {},
    };

    return bless $self, $class;
}

sub run_parser {
    my $self = shift;
    my $lines = shift;

    my $process_line = sub {
        my $els  = $_[0]->{ elements   };
        my $attr = $_[0]->{ attributes };

        # skip some features
        return if $els->[ FEATURE ] =~ m/^(gene|transposable_element_gene|chromosome|protein|pseudogene)$/;

        # get an ID, either from the ID, or from the Parent attr
        my $ID   = exists $attr->{ ID }
                         ? $attr->{ ID }
                         : $attr->{ Parent };
        if ($ID =~ /(.*),/) { # multi value Parents, only take the first one
            $ID = $1;
        }
        my $gene = ! exists $self->{ genes }->{ $ID } ? $self->init_gene($els, $ID) : $self->{ genes }->{ $ID };

        # The structure is only two leveled: feature -> somekind of exon
        FEAT:
        for ($els->[ FEATURE ]) {
            /^(mRNA|mRNA_TE_gene|pseudogenic_transcript|snRNA|rRNA|ncRNA|tRNA|snoRNA|miRNA|transposable_element)$/i && do {
                # we need to overwrite the start-stop coords as these might have been filled with exon coords from the init_gene
                $gene->{ start } = $els->[ START ];
                $gene->{ stop  } = $els->[ STOP  ];
                $gene->{ type  } = $els->[ FEATURE ];
                last FEAT;
            };
            /^(exon|pseudogenic_exon|transposon_fragment|five_prime_UTR|three_prime_UTR|CDS)$/i && do {
                last FEAT if $gene->{ type } eq 'mRNA' && $els->[ FEATURE ] eq 'exon'; # if coding genes, only check 5', 3' and CDS
                push @{ $gene->{ coords } }, {
                    start => $els->[ START ],
                    stop  => $els->[ STOP ],
                    type  => $self->get_struct_type($els->[ FEATURE ]),
                };
                last FEAT;
            };
            /.*/ && do {
                return;
            }
        }
        return; # we actually don't need to give anything back the GFF::Parser as we are building the datastructure
    };

    $self->{ parser }->parse($lines, $process_line);
    return $self->{ genes };
}

sub get_struct_type {
    my $self = shift;
    my $type = shift;

    for ($type) {
        /^five_prime|^three_prime/i && do {
            return "utr";
        };
        /CDS/i && do {
            return 'cds';
        };
    }
    return q{};
}

sub init_gene {
    my $self = shift;
    my $els = shift;
    my $ID  = shift;
    return $self->{ genes }->{ $ID } = { 
        strand => $els->[ STRAND ],
        'chr'  => $els->[ CHR ],
        type   => $els->[ FEATURE ],
        seq    => q{},
        start  => $els->[ START ], # are we sure mRNA start-stop coords == gene start-stop coords ?
        stop   => $els->[ STOP ],
        coords => [],
    };
}

sub make_SQL {
    my $self = shift;
    my @result = ();

    while (my ($acc_model_nr, $gene) = each %{ $self->{ genes } }) {
        my ($acc_nr, $model_nr) = split /\./, $acc_model_nr;
        $gene->{ acc_nr } = $acc_nr;
        $gene->{ model_nr } = $model_nr;
        my $coords = $gene->{ coords };

        foreach my $key (keys %$gene) {
            $gene->{ $key } = $self->{ dbh }->quote($gene->{ $key });
        }
        
        my $annotation_id = $self->get_next_id;
        push @result, <<"";
INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, `chr`, `type`)
VALUES ($annotation_id $gene->{ acc_nr }, $gene->{ model_nr }, $gene->{ start }, $gene->{ stop }, $gene->{ strand }, $gene->{ 'chr' }, $gene->{ type });

        foreach my $coord ( @{ $coords }) {
            my $type = $coord->{ type } eq q{cds} ? 'N' : 'Y';
            $type = $self->{ dbh }->quote($type);
            push @result, <<"";
INSERT INTO `structures` (annotation_id, start, stop, utr)
VALUES ($annotation_id, $coord->{ start }, $coord->{ stop }, $type);

        }
    }
    
    return \@result;
}

{ 
    my $last_insert_id = 0;

    sub get_next_id {
        my $self = shift;

        if (!$last_insert_id) {
            $last_insert_id = $self->{ dbh }->selectrow_arrayref(q{SELECT LAST_INSERT_ID()})->[0];
        }

        return ++$last_insert_id;
    }

    sub get_cur_id {
        return $last_insert_id;
    }
}

1;

__END__
