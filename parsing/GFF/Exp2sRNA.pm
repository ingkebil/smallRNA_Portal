package GFF::Exp2sRNA;

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use DBI;

use GFF q/:GFF_SLOTS/;
use constant NAME      => FRAME + 1;
use constant SEQ_ID    => FRAME + 2;
use constant TYPE_ID   => FRAME + 3;
use constant ABUNDANCE => FRAME + 4;
use constant EXP_ID    => FRAME + 5;

use Settings q/:DB/;
use GFF::Parser;
use FASTA::Reader;
use SRNA::DBAbstract;

&run() unless caller;

sub run {
    my $gfffile = q{};
    my ($exp_id, $species_id) = 0;
    my ($path, $type, $fasta_file, $fasta_id_regex, $chr_fasta) = q{};

    my $opts = GetOptions(
        'experiment_id=i' => \$exp_id,
        'type=s' => \$type,
        'path:s' => \$path,
        'fasta:s' => \$fasta_file,
        'fasta_id_regex:s' => \$fasta_id_regex,
        'chrfasta:s' => \$chr_fasta,
        'speciesid:i' => \$species_id,
    );

    pod2usage(2) if (! $exp_id && ! $type && !$ARGV[0]);

    print 'Reading GFF ... ';
    open F, '<', $ARGV[0] or die "$ARGV[0] not found!\n";
    my @lines = <F>; ### Reading GFF [%]
    close F;
    print "done.\n";
    my $exp2srna = __PACKAGE__->new({ fasta => $fasta_file, fasta_id_regex => $fasta_id_regex, chr_fasta => $chr_fasta });

    print 'Parsing GFF ... ';
    $exp2srna->run_parser(\@lines, $exp_id, $type, $species_id);
    print "done.\n";

    while (my ($outputtype, $results) = each %{ $exp2srna->{ return }->{ csv } }) {
        $exp2srna->fprint("$path/$outputtype.csv", join("\n", @{ $results }));
    }
}

sub fprint {
    my $self = shift;
    my $file = shift;
    my $content = shift;

    if (open(F, '>', $file)) {
        print F $content;
        close F;
    }
    else {
        warn "Failed to write to $file!";
    }
}

sub new {
    my $inv = shift;
    my $s = shift;
    my $fasta_file = $s->{ fasta };
    my $fasta_id_regex = $s->{ fasta_id_regex };
    my $chr_fasta = $s->{ chr_fasta };
    my $user = $s->{ user } || USER;
    my $pass = $s->{ pass } || PASS;
    my $db   = $s->{ db   } || DB;

    my $class = ref $inv || $inv;

    my $gff = new GFF::Parser();
    my $dbh = DBI->connect('dbi:mysql:database='. $db, $user, $pass) or die "Could not connect to DB\n";
    my $chroms = new SRNA::DBAbstract({ dbh => $dbh, table => 'chromosomes' });

    my $self = {
        parser => $gff,
        dbh    => $dbh,
        chroms => $chroms,
        chr_fasta => $chr_fasta,
        return => { csv => { srnas => [], sequences => [], types => [] } },
    };

    if ($fasta_file) {
        print 'Reading FASTA ... ';
        $fasta_id_regex = $fasta_id_regex || '>(.*)';

        my $freader = new FASTA::Reader({ filename => $fasta_file, id_regex => $fasta_id_regex});
        $self->{ freader        } = $freader;
        $self->{ fasta_file     } = $fasta_file;
        $self->{ fasta_id_regex } = $fasta_id_regex;

        print "done.\n";
    }

    return bless $self, $class;
}

sub run_parser {
    my $self = shift;
    my $lines = shift;
    my $exp_id = shift;
    my $type = shift;
    my $species_id = shift;

    # well, if we parsed already, don't do it again!
    return $self->{ return }->{ csv }->{ srnas } if (@{ $self->{ return }->{ csv }->{ srnas } });

    my $els = $self->{ parser }->parse($lines);

    return $self->{ return }->{ csv }->{ srnas } = $self->make_output($els, $exp_id, $type, $species_id);
}

sub make_output {
    my $self = shift;
    my $els  = shift;
    my $exp_id = shift;
    my $type = shift;
    my $species_id = shift;

    my @lines = ();
    print 'Starting generating output ...';
    foreach my $el (@{ $els }) { ### [%]
        my $line = q{};
        my $id = $self->get_next_id;

        # check the type
        my $type_id = $self->add_type($type);
        @{ $el->{ elements } }[ TYPE_ID ] = $type_id;

        # add the exp_id
        @{ $el->{ elements } }[ EXP_ID ] = $exp_id;

        # add the name
        my @attrs = keys %{ $el->{ attributes } }; # add the name
        @{ $el->{ elements } }[ NAME ] = $attrs[0];

        # get the abundance
        (my $abundance = $el->{ elements }->[ NAME ]) =~ s/.*x(\d+)/$1/;
        @{ $el->{ elements } }[ ABUNDANCE ] = $abundance;

        # get the sequence
        my $seq = undef;
        if (exists $self->{ freader }) {
            my $freader = $self->{ freader };
            $seq = $freader->get_seq($self->{ fasta_file }, $el->{ elements }->[ NAME ]); 
        }

        # look up if the seq already is stored in the db
        my $seq_id = undef;
        if ($seq) {
            $seq_id = $self->add_seq($seq);
        }
        @{ $el->{ elements } }[ SEQ_ID ] = $seq_id;

        # get the chrom id
        my $chroms = $self->{ chroms };
        my $chr_name = ucfirst @{  $el->{ elements }  }[ CHR ];
        my $chr_id = $chroms->get_id(name => $chr_name);
        if ( ! $chr_id) {
            if ( ! exists $self->{ freader }) {
                print 'Reading chromosomes FASTA ...';
                $self->{ freader } = new FASTA::Reader({ filename => $self->{ chr_fasta }, 'id_regex' => '>(.*)' });
                print "done.\n";
            }
            my $freader = $self->{ freader };
            $freader->add_regex($self->{ chr_fasta } => '>(.*)');
            my $chr_len = length $freader->get_seq($self->{ chr_fasta }, $chr_name);
            $chr_id = $chroms->add({ name => $chr_name, length => $chr_len, species_id => $species_id });
            $self->{ return }->{ csv }->{ chromosomes } = $chroms->get_new_rows_CSV('id', 'name', 'length', 'species_id');
        }
        @{ $el->{ elements } }[ CHR ] = $chr_id;

        # quote for the DB
        my @e = map { $self->{ dbh }->quote($_) } @{ $el->{ elements } };

        my $undef = $self->{ dbh }->quote(undef);

        # make the output
        $line  = $id;
        $line .= "\t" . $e[ NAME      ];
        $line .= "\t" . $e[ START     ];
        $line .= "\t" . $e[ STOP      ];
        $line .= "\t" . $e[ STRAND    ];
        $line .= "\t" . $e[ SEQ_ID    ];
        $line .= "\t" . $e[ SCORE     ];
        $line .= "\t" . $e[ TYPE_ID   ];
        $line .= "\t" . $e[ ABUNDANCE ];
        $line .= "\t" . $undef;
        $line .= "\t" . $e[ EXP_ID    ];
        $line .= "\t" . $e[ CHR       ];

        push @lines, $line;
    }
    print "done.\n";

    return \@lines;
}

#sub seq_sql_adder {
#    my $self = shift;
#
#    @_ = map { $self->{ dbh }->quote($_) } @_;
#    
#    push @{ $self->{ return }->{ sql }->{ seq } }, "INSERT INTO `sequences` (id, seq) VALUES ($_[0], $_[1])";
#}
#
#sub type_sql_adder {
#    my $self = shift;
#
#    @_ = map { $self->{ dbh }->quote($_) } @_;
#    
#    push @{ $self->{ return }->{ sql }->{ type } }, "INSERT INTO `types` (id, name) VALUES ($_[0], $_[1])";
#}

sub csv_adder {
    my $self = shift;
    my $type = shift;

    push @{ $self->{ return }->{ csv }->{ $type } },
        join qq{\t},
        map { $self->{ dbh }->quote($_); }
        @_;
}

{
    my $last_insert_id = 0;
    my %seqs= (); # seq => id

    sub add_seq {
        my $self = shift;
        my $seq  = shift;

        if (! exists($seqs{ $seq })) {
            my $seq_id = $self->{ dbh }->selectrow_arrayref(q{SELECT id FROM `sequences` WHERE seq = ?}, {}, ( $seq ));
            if (! $seq_id) {
                if (!$last_insert_id) {
                    $last_insert_id = $self->{ dbh }->selectrow_arrayref(q{SELECT MAX(id) FROM `sequences`})->[0];
                }

                $self->csv_adder('sequences', ++$last_insert_id, $seq);

                $seqs{ $seq } = $last_insert_id;
            }
            else {
                $seqs{ $seq } = $seq_id->[0];
            }
        }

        return $seqs{ $seq };
    }
}

{
    my $last_insert_id = 0;
    my %types = (); # type => id

    sub add_type {
        my $self = shift;
        my $type = shift;

        if (! exists($types{ $type })) {
            my $type_id = $self->{ dbh }->selectrow_arrayref(q{SELECT id FROM `types` WHERE name = ? }, {}, ( $type ));
            if (! $type_id ) {
                if (!$last_insert_id) {
                    $last_insert_id = $self->{ dbh }->selectrow_arrayref(q{SELECT MAX(id) FROM `types`})->[0];
                }

                $self->csv_adder('types', ++$last_insert_id, $type);

                $types{ $type } = $last_insert_id;
            }
            else {
                $types{ $type } = $type_id->[0];
            }
        }

        return $types{ $type };
    }
}


{ 
my $last_insert_id = 0;

sub get_next_id {
    my $self = shift;

    if (!$last_insert_id) {
        $last_insert_id = $self->{ dbh }->selectrow_arrayref(q{SELECT MAX(id) FROM `srnas`;})->[0];
    }

    return ++$last_insert_id;
}

sub get_cur_id {
    return $last_insert_id;
}
}

1;

__END__

=head1 NAME

Exp2sRNA - Parsing GFF files into CSV statements for the smallRNA database;

=head1 SYNOPSIS

Usage: Exp2sRNA [options] gfffile

Exp2sRNA parses a smallRNA GFF file into a CSV. Two files will be generated:
srnas.csv and types.cvs. The latter will containt the new entries for the types
table.  If a fasta file is provided with the --fasta param, a sequences.csv
file will also be generated.

    Options:
        --experiment_id: The id of the experiment as stored in the database. This id will be used in the generation of the CSV.
        --type: The name of the smallRNA type. If this does not exist in the DB, a types.csv file will be generated.
        --path: The output directory to place the CSV files.
            * srnas.csv
            * sequences.csv
            * types.csv
        --fasta: The fasta file. If provided, a sequence.csv file will be generated.
        --fasta_id_regex: The regex to extract an ID from the fasta file headers. The ID should be surrounded by round brackets () in the regex. Defaults to '>(.*)'.
        --chrfasta: The fasta file for the chromosomes. Just in case these have not been added to the DB yet.
        --speciesid: The id of the species in the DB.
        
To upload the CSV files into the DB use following command:
mysqlimport -u <username> -p -L --fields-enclosed-by \' <filename.csv>

=head1 AUTHOR

Kenny Billiau
