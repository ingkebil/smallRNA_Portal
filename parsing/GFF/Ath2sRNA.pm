#!usr/bin/perl
package GFF::Ath2sRNA;

use strict;
use warnings;
use Smart::Comments;
use Data::Dumper;
use GFF q/:GFF_SLOTS/;
use Settings q/:DB/;
use GFF::Parser;
use FASTA::Reader;
use DBI;
use Getopt::Long;
use Pod::Usage;

# only run when modulino is used as a script and not a module
&run() unless caller;

our $path = q{}; # put as a global so we can test

=head1 
public static void main string args ;)
=cut
sub run {
    my $gfffile = q{};
    my ($source_id, $species_id, $csv) = 0;
    my ($species_name, $source_name, $fasta_file, $fasta_id_regex) = q{};

    my $opts = GetOptions(
        'sourceid:i' => \$source_id,
        'sourcename:s' => \$source_name,
        'speciesid:i' => \$species_id,
        'speciesname:s' => \$species_name,
        'path:s' => \$path,
        'fasta:s' => \$fasta_file,
        'fasta_id_regex:s' => \$fasta_id_regex,
    );

    pod2usage(2) if (! $source_id && ! $source_name);
    pod2usage(2) if (! $species_id && ! $species_name);

    open F, '<', $ARGV[0] or pod2usage(3);
    my @lines = <F>; ### Reading file [%]
    close F;

    my $ath2srna = __PACKAGE__->new($fasta_file, $fasta_id_regex);
    $source_id = $ath2srna->check_source($source_id, $source_name);
    $species_id = $ath2srna->check_species($species_id, $species_name);

    $ath2srna->run_parser(\@lines);

    if ($path) { # if we want CSV
        my $results = $ath2srna->make_CSV($source_id, $species_id);
        $path .= q{/} if substr($path, -1, 1) ne q{/};

        $ath2srna->fprint($path . 'annotations.csv', join( "\n", @{ $results->{ annotations } }));
        $ath2srna->fprint($path . 'structures.csv', join( "\n", @{ $results->{ structures } }));
        $ath2srna->fprint($path . 'chromosomes.csv', join( "\n", @{ $results->{ chromosomes } }));
        $ath2srna->fprint($path . 'ath.sql',        join( "\n", @{ $results->{ sql } }));
    }
    else { # no, we want plain old slow SQL!
        print "SET foreign_key_constraints=0;\n";
        print @{ $ath2srna->make_SQL($source_id, $species_id) };
        print "SET foreign_key_constraints=1;\n";
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
    my $class = ref $inv || $inv;

    my ($fasta_file, $fasta_id_regex) = @_;

    my $gff = new GFF::Parser();
    my $dbh = DBI->connect('dbi:mysql:database='.DB, USER, PASS) or die "Could not connect to DB\n";

    my $self = {
        parser => $gff,
        dbh    => $dbh,
        # structure is we want to get is something like this, which litterally translates to the DB scheme
        # { acc_nr.model_nr => { strand, chr, type, seq, start, stop, struct, coords => [{ start, stop, type => 5', 3', cds, '' }] } }
        genes   => {},
    };

    if ($fasta_file) {
        $fasta_id_regex = $fasta_id_regex || '>(.*)';

        my $freader = new FASTA::Reader({ filename => $fasta_file, id_regex => $fasta_id_regex });
        $self->{ freader        } = $freader;
        $self->{ fasta_file     } = $fasta_file;
        $self->{ fasta_id_regex } = $fasta_id_regex;
    }

    return bless $self, $class;
}

sub check_source {
    my $self = shift;
    my ($sid, $sname) = @_;

    if ($sid) {
        my $q_sid   = $self->{ dbh }->quote($sid);
        my $count = $self->{ dbh }->selectcol_arrayref(qq{SELECT count(*) FROM `sources` WHERE id = $q_sid})->[0];

        warn "Sources ID '$sid' is not found in the DB. Make sure you've already added it or foreign key constraints will tair the galaxy part!" if ! $count;
    }
    elsif ($sname) {
        my $q_sname = $self->{ dbh }->quote(qq{%$sname%});
        $sid = $self->{ dbh }->selectcol_arrayref(qq{SELECT id FROM `sources` WHERE name LIKE $q_sname})->[0];

        die "'$sname' is not found in the DB. The program needs a correct name to look up the source ID so we can link the annotation to the right source!" if ! $sid;
    }

    return $sid;
}

sub check_species {
    my $self = shift;
    my ($sid, $sname) = @_;

    if ($sid) {
        my $q_sid   = $self->{ dbh }->quote($sid);
        my $count = $self->{ dbh }->selectcol_arrayref(qq{SELECT count(*) FROM `species` WHERE id = $q_sid})->[0];

        warn "Species ID '$sid' is not found in the DB. Make sure you've already added it or foreign key constraints will tair the galaxy part!" if ! $count;
    }
    elsif ($sname) {
        my $q_sname = $self->{ dbh }->quote(qq{%$sname%});
        $sid = $self->{ dbh }->selectcol_arrayref(qq{SELECT id FROM `species` WHERE full_name LIKE $q_sname})->[0];

        die "'$sname' is not found in the DB. The program needs a correct name to look up the species ID so we can link the annotation to the right species!" if ! $sid;
    }

    return $sid;
}

sub run_parser {
    my $self = shift;
    my $lines = shift;

    # well, if we parsed already, don't do it again!
    return $self->{ genes } if (%{ $self->{ genes } });

    my $process_line = sub {
        my $els  = $_[0]->{ elements   };
        my $attr = $_[0]->{ attributes };

        # skip some features
        return if $els->[ FEATURE ] =~ m/^(gene|transposable_element_gene|chromosome|protein|pseudogene)$/;

        # get an ID, either from the ID, or from the Parent attr
        my $ID   = exists $attr->{ ID } ? $attr->{ ID } : $attr->{ Parent };
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
                last FEAT if $gene->{ type } eq 'mRNA' && $els->[ FEATURE ] eq 'exon'; # if coding genes, only check 5', 3' and CDS (so skip the only remianing element, the exon)
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
        return; # we actually don't need to give anything back the GFF::Parser as we are building the datastructure ourselves
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

{

# because the make subs were so similar with the exception on how they add data to certain structures
# I decided to make this complex setup with add-subs and return-subs.

my @annotations = ();
my @sql = ();
my @structures = ();
my @chromosomes = ();


## The adders
sub add_annotation {
    push @annotations, join("\t", @_);
}

sub add_chromosome {
    push @chromosomes, join("\t", @_);
}

sub add_sql {
    push @sql, $_[0];
}

sub add_annotation_sql {
    push @sql, 'INSERT INTO `annotations` (id, accession_nr, model_nr, start, stop, strand, chromosome_id, `type`, species_id, seq, comment, source_id)
VALUES (' . join(q{, }, @_) . ');
';
}

sub add_structure_sql {
    push @sql, 'INSERT INTO `structures` (id, annotation_id, start, stop, utr)
VALUES (' . join(q{, }, @_) . ');
';
}

sub add_structure {
    push @structures, join("\t", @_);
}

sub add_chromosome_sql {
    push @sql, 'INSERT INTO `chromosomes` (id, name, length)
VALUES (' . join(q{, }, @_) . ');
';
}

## the returners
sub return_sql {
    return \@sql;
}

sub return_csv {
    return { annotations => \@annotations, structures => \@structures, chromosomes => \@chromosomes, sql => \@sql };
}

## the actual functions 

sub reset_make {
    @annotations = ();
    @structures  = ();
    @chromosomes = ();
    &reset_chr_ids();

    @sql = ();
}

sub make_CSV {
    my $self = shift;

    $self->reset_make;

    return $self->make_output({
            annotation_adder => \&add_annotation,
            structure_adder  => \&add_structure,
            chromosome_adder => \&add_chromosome,
            sql_adder        => \&add_sql,
            returner         => \&return_csv,
        }, @_);
}

sub make_SQL {
    my $self = shift;

    $self->reset_make;
    
    return $self->make_output({
            annotation_adder => \&add_annotation_sql,
            structure_adder  => \&add_structure_sql,
            chromosome_adder => \&add_chromosome_sql,
            sql_adder        => \&add_sql,
            returner         => \&return_sql,

        }, @_);
}

## don't call this directly, use the make_CSV and make_SQL functions
sub make_output {
    my $self = shift;
    my $handlers = shift;
    my $sid  = shift;
    my $soid  = shift;

    my $features = $self->get_features();

    while (my ($acc_model_nr, $gene) = each %{ $self->{ genes } }) {
        my ($acc_nr, $model_nr) = split /\./, $acc_model_nr;
        $gene->{ acc_nr } = $acc_nr;
        $gene->{ model_nr } = $model_nr || 1;
        $gene->{ source_id } = $sid;
        $gene->{ species_id } = $soid;

        # check if the feature exists
        if (! exists $features->{ $gene->{ type } }) {
            $features->{ $gene->{ type } } = 1;
        }

        # get the seq
        my $seq = undef;
        if (exists $self->{ freader }) {
            my $freader = $self->{ freader };
            $seq = $freader->get_seq($self->{ fasta_file }, $gene->{ 'chr' }); 
            $seq = substr($seq, $gene->{ start }, $gene->{ stop } - $gene->{ start });
        }
        $gene->{ seq } = $seq ? $seq : undef;

        ## now replace the chr with the chr id in the chromsomes table
        # first get the chr_id
        my $chr_id = $self->get_chr_id($gene->{ 'chr' }, $handlers);
        $gene->{ chr_id } = $chr_id;

        # quote for the DB
        my $g = {};
        foreach my $key (keys %$gene) {
            $g->{ $key } = $self->{ dbh }->quote($gene->{ $key });
        }
        my $undef = $self->{ dbh }->quote(undef);

        # if we want to reuse the $genes, we add the $annotation_id 
        # to its hash to prevent inc'ing the id after each call
        my $annotation_id = exists $gene->{ id } ? $gene->{ id } : $self->get_next_id;
        $gene->{ id } = $annotation_id;

        $handlers->{ annotation_adder }(
            $annotation_id,
            $g->{ acc_nr },
            $g->{ model_nr },
            $g->{ start },
            $g->{ stop },
            $g->{ strand },
            $g->{ chr_id },
            $g->{ type },
            $g->{ species_id },
            $g->{ seq },
            $undef,
            $g->{ source_id }
        );

        foreach my $coord ( @{ $gene->{ coords } }) {
            my $type = $coord->{ type } eq q{cds} ? 'N' : 'Y';
            $type = $self->{ dbh }->quote($type);
            $handlers->{ structure_adder }(
                $undef,
                $annotation_id,
                $coord->{ start },
                $coord->{ stop },
                $type
            );
        }
    }

    # check if the feature set differs compared to the original
    my $ori_features = $self->get_features();
    if (grep ! exists $ori_features->{ $_ }, keys %$features) {
        my $feats = join q{','}, keys %$features;
        $feats = q{'} . $feats . q{'};  
        $handlers->{ sql_adder }("ALTER TABLE annotations MODIFY type enum($feats);\n");
    }

    return &{ $handlers->{ returner } };
}

}

## CHROMOSOME STUFF

sub get_chrs {
    my $self = shift;
    my $chr  = shift;

    my $sql = 'SELECT id, name FROM chromosomes WHERE name = ?';
    return $self->{ dbh }->selectall_arrayref($sql, { Slice => {} }, ( $chr ));
}

{

my %chr_ids = ();
my $last_insert_id = 0;

sub reset_chr_ids {
    $last_insert_id = 0;
    %chr_ids = ();
}

sub get_chr_id {
    my $self = shift;
    my $chr  = shift;
    my $handlers = shift;

    if (exists $chr_ids{ $chr }) {
        return $chr_ids{ $chr };
    }

    my $rs = $self->{ dbh }->selectcol_arrayref('SELECT id FROM chromosomes WHERE name = ?', { MaxRows => 1 }, ( $chr ));

    if (! scalar @$rs) {
        my $chr_length = undef;
        if (exists $self->{ freader }) {
            my $freader = $self->{ freader };
            $chr_length = length($self->{ freader }->get_seq($self->{ fasta_file }, $chr));
        }
        
        my $chr_id = $self->get_next_chr_id();
        $self->add_chr_id($chr, $chr_id);
        $handlers->{ chromosome_adder }(
            $chr_id,
            $chr,
            $chr_length
        );
        return $chr_id;
    }
    else {
        $self->add_chr_id($chr, $rs->[ 0 ]);
        return $rs->[ 0 ]; # first row, first column
    }
}

sub get_next_chr_id {
    my $self = shift;

    if (!$last_insert_id) {
        $last_insert_id = $self->{ dbh }->selectrow_arrayref(q{SELECT max(id) FROM `chromosomes`})->[0];
    }

    return ++$last_insert_id;
}

sub add_chr_id {
    my $self = shift;
    my $chr = shift;
    my $chr_id = shift;

    $chr_ids{ $chr } = $chr_id;
}

}

## FEATURE STUFF


sub get_features {
    my $self = shift;

    my %features = map { s/enum\('|'\)//g; $_, 1 }
    split /','/,
    $self->{ dbh }->selectrow_hashref("SHOW columns FROM annotations WHERE field = 'type'")->{Type};

    return \%features;
}

## ANNOTATION STUFF


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

=head1 NAME

Ath2sRNA - Parsing GFF files into SQL/CSV statements for the smallRNA database;

=head1 SYNOPSIS

Ath2sRNA [options] GFFfile

By default, the parser will output SQL statements. To output CSV add the --path parameter.

Required parameters: 

  --sourceid <id> | --sourcename <name>: The ID or the name of the source as provided in the DB, table 'sources'. When giving the sourcename a DB lookup is done to get the sourceid.
  --speciesid <id>| --speciesname <name>: The ID or the name of the species as provided in the DB, table 'species'. When giving the speciesname a DB lookup is done to get the speciesid.


Optional:

  --fasta <file>: The FASTA file where to cut the sequences out.
  --fasta_id_regex <regex>: The regex to extract the id from the FASTA file. Default takes the whole line without the leading '>'.
  --path <path>: Specify a path where to put output files. This will also put the parser into CSV mode and output three files:
                    * annotations.csv
                    * structures.csv
                    * ath.sql : containing possible table alterations.
   Import the table alterations with: mysql -u <username> -p smallrna < ath.sql
   Import the CSV with: mysqlimport -u <username> -p --fields-enclosed-by \' -L smallrna annotations.csv 


=head1 AUTHOR

Kenny Billiau

