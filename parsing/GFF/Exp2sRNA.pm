package GFF::Exp2sRNA;

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use Smart::Comments;
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
use SRNA::DNAUtils;

&run() unless caller;

sub run {
    my $gfffile = q{};
    my ($exp_id, $species_id, $writebuffer) = 0;
    my ($path, $type, $fasta_file, $fasta_id_regex, $chr_fasta) = q{};

    my $opts = GetOptions(
        'experiment_id=i' => \$exp_id,
        'type=s' => \$type,
        'path:s' => \$path,
        'fasta:s' => \$fasta_file,
        'fasta_id_regex:s' => \$fasta_id_regex,
        'chrfasta:s' => \$chr_fasta,
        'speciesid:i' => \$species_id,
        'writebuffer' => \$writebuffer,
    );

    pod2usage(2) if (! $exp_id && ! $type && !$ARGV[0]);

    my $exp2srna = __PACKAGE__->new({ fasta => $fasta_file, fasta_id_regex => $fasta_id_regex, chr_fasta => $chr_fasta });

    ### Parsing GFF $ARGV[0] ...
    open F, '<', $ARGV[0] or die "$ARGV[0] not found!\n";

    # following block of code parses the GFF file in chuncks to prevent out of memory errors :)
    $writebuffer ||= 300_000;
    my @lines = ();
    my $i = 0;
    my $j = 0;
    my $return = { srnas => [], sequences => [], types => [] };
    while (my $line = <F>) { 
        push @lines, $line;
        $i++;
        if ($i == $writebuffer) {
            $j++;
            $exp2srna->run_parser(\@lines, $exp_id, $type, $species_id);
            $exp2srna->export_to_CSV($path, $j); # export to file
            #else {
            #    foreach my $key (keys %$return) {
            #        $return->{ $key } = [ @{ $return->{ $key } }, @{ $exp2srna->{ return }->{ csv }->{ $key } } ];
            #    }
            #}

            $exp2srna->{ return } = { csv => { srnas => [], sequences => [], types => [] } },
            @lines = ();
            $i = 0;
        }
    }
    close F;
    if (@lines) {
        $exp2srna->run_parser(\@lines, $exp_id, $type, $species_id);
        $exp2srna->export_to_CSV($path, ++$j); # export to file
        #else {
        #    foreach my $key (keys %$return) {
        #        $return->{ $key } = [ @{ $return->{ $key } }, @{ $exp2srna->{ return }->{ csv }->{ $key } } ];
        #    }
        #}
    }
    ### tried $j times ...
    # if (!$hotrun) {
    #     $exp2srna->{ return }->{ csv } = $return;
    #     $exp2srna->export_to_CSV($path);
    # }
}

sub export_to_CSV {
    my $self = shift;
    my $path = shift;
    my $suff = shift;

    while (my ($outputtype, $results) = each %{ $self->{ return }->{ csv } }) {
        $self->fprint("$path/$outputtype.$suff.csv", join("\n", @{ $results }));
    }
}

sub import_in_DB {
    my $self = shift;
    my $path = shift;

    my $user = $self->{ user };
    my $pass = $self->{ pass };
    my $db   = $self->{ db };

    while (my ($outputtype, $results) = each %{ $self->{ return }->{ csv } }) {
        print "mysqlimport -u $user -p --fields-enclosed-by \\' $db < $path/$outputtype.csv\n";
        `mysqlimport -u $user -p$pass --fields-enclosed-by \\' $db < $path/$outputtype.csv`;
    }
}

sub fprint {
    my $self = shift;
    my $file = shift;
    my $content = shift;

    if (open(FF, '>', $file)) {
        print FF $content;
        close FF;
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
    my $utils = new SRNA::DNAUtils();

    my $self = {
        parser => $gff,
        dbh    => $dbh,
        chroms => $chroms,
        utils  => $utils,
        chr_fasta => $chr_fasta,
        user => $user,
        pass => $pass,
        db  => $db,
        return => { csv => { srnas => [], sequences => [], types => [] } },
    };

    if ($chr_fasta || $fasta_file) {
        $self->{ freader } = new FASTA::Reader({});
    }
    if ($chr_fasta) {
        ### Parsing FASTA $self->{ chr_fasta } ...
        $self->{ freader }->add_regex($chr_fasta => '>(.*)');
        $self->{ freader }->_fasta($self->{ chr_fasta }); # force read
    }
    if ($fasta_file) {
        ### Parsing FASTA $fasta_file ...
        $fasta_id_regex = $fasta_id_regex || '>(.*)';

        $self->{ freader }->add_regex($fasta_file => $fasta_id_regex);
        $self->{ freader }->_fasta($fasta_file); # force read
        $self->{ fasta_file     } = $fasta_file;
        $self->{ fasta_id_regex } = $fasta_id_regex;
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
    ### Generating output ...
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
        @{ $el->{ elements } }[ SEQ_ID ] = $seq_id || 1;

        # get the chrom id
        my $chroms = $self->{ chroms };
        my $chr_name = ucfirst @{  $el->{ elements }  }[ CHR ];
        my $chr_id = $chroms->get_id(name => $chr_name);
        if ( ! $chr_id && $self->{ chr_fasta }) {
            my $chr_len = length ${ $self->{ freader }->get_seq_ref($self->{ chr_fasta }, $chr_name) };
            $chr_id = $chroms->add({ name => $chr_name, length => $chr_len, species_id => $species_id });
            $self->{ return }->{ csv }->{ chromosomes } = $chroms->get_new_rows_CSV('id', 'name', 'length', 'species_id');
        }
        @{ $el->{ elements } }[ CHR ] = $chr_id;

        # check for mismatches, if the chr seq is available
        if ($self->{ chr_fasta }) {
            my $mms = $self->check_mismatch($el->{ elements }, $seq, $chr_name);
            foreach my $mm (@$mms) {
                $self->csv_adder('mismatches', undef, $id, $mm);
            }
        }

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

    return \@lines;
}

sub check_mismatch {
    my $self = shift;
    my $srna = shift;
    my $seq  = shift;
    my $chrom_name = shift;
   
    #my $ref_seq_spl = $self->{ freader }->get_seq_arrayref($self->{ chr_fasta }, $chrom_name);
    my $ref_seq_ref = $self->{ freader }->get_seq_ref($self->{ chr_fasta }, $chrom_name);
    return () if ! ref $ref_seq_ref;
    my $ref_seq = substr($$ref_seq_ref, $srna->[ START ] -1, $srna->[ STOP ] - $srna->[ START ] + 1);
    if ($srna->[ STRAND ] eq q{-}) {
        $ref_seq = reverse $ref_seq;
        $ref_seq = ${ $self->{ utils }->full_complement(\$ref_seq) };
    }
    my @ref_seq_spl = split //, $ref_seq;
    my @srna_seq_spl = split //, $seq;

    my @mm = ();
    for (my $i = 0; $i < $srna->[ STOP ] - $srna->[ START ] + 1; $i++) {
        if ($ref_seq_spl[ $i ] ne $srna_seq_spl[ $i ]) {
            push @mm, $srna->[ START ] + $i;
        }
    }

    return \@mm;
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

Exp2sRNA parses a smallRNA GFF file into a CSV. Two sorts of files will be
generated: srnas.#.csv and types.#.cvs. The latter will containt the new entries
for the types table.  If a fasta file is provided with the --fasta param, a
sequences.#.csv file will also be generated.  The # will be replaced by a
number. Every 1_000_000 lines ofthe mappnig file, the CSV files are dumped to
prevent OEM errors. If this would still be insufficient, you can adapt the
internal buffersize with the --writebuffer param.

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
        --writebuffer: After how many lines of the mapping file the CSV files should be written. Defaults to 1_000_000
        
To upload the CSV files into the DB use following command:
mysqlimport -u <username> -p -L --fields-enclosed-by \' <filename.csv>

=head1 AUTHOR

Kenny Billiau
