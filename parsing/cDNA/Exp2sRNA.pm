package cDNA::Exp2sRNA;

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use Smart::Comments;
use DBI;

use Settings q/:DB/;
use FASTA::Reader;
use SRNA::DBAbstract;
use SRNA::DNAUtils;

&run() unless caller;

sub run {
    my $gfffile = q{};
    my ($exp_id, $species_id, $writebuffer) = 0;
    my ($path, $type, $fasta_file, $fasta_id_regex) = q{};

    my $opts = GetOptions(
        'experiment_id=i' => \$exp_id,
        'type=s' => \$type,
        'path:s' => \$path,
        'fasta:s' => \$fasta_file,
        'fasta_id_regex:s' => \$fasta_id_regex,
        'writebuffer' => \$writebuffer,
    );

    pod2usage(2) if (! $exp_id && ! $type && !$ARGV[0]);

    my $exp2srna = __PACKAGE__->new({ fasta => $fasta_file, fasta_id_regex => $fasta_id_regex });

    ### Parsing $ARGV[0] ...
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
            $exp2srna->run_parser(\@lines, $exp_id, $type);
            $exp2srna->export_to_CSV($path, $j); # export to file

            $exp2srna->{ return } = { csv => { srnas => [], sequences => [], types => [] } },
            @lines = ();
            $i = 0;
        }
    }
    close F;
    if (@lines) {
        $exp2srna->run_parser(\@lines, $exp_id, $type, $species_id);
        $exp2srna->export_to_CSV($path, ++$j); # export to file
    }
    ### tried $j times ...
}

sub export_to_CSV {
    my $self = shift;
    my $path = shift;
    my $suff = shift;

    while (my ($outputtype, $results) = each %{ $self->{ return }->{ csv } }) {
        $self->fprint("$path/$outputtype.$suff.csv", join("\n", @{ $results }));
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
    my $user = $s->{ user } || USER;
    my $pass = $s->{ pass } || PASS;
    my $db   = $s->{ db   } || DB;

    my $class = ref $inv || $inv;

    my $dbh = DBI->connect('dbi:mysql:database='. $db, $user, $pass) or die "Could not connect to DB\n";
    my $utils = new SRNA::DNAUtils();

    my $self = {
        dbh    => $dbh,
        utils  => $utils,
        user => $user,
        pass => $pass,
        db  => $db,
        return => { csv => { srnas => [], sequences => [], types => [] } },
    };

    if ($fasta_file) {
        ### Parsing FASTA $fasta_file ...
        $fasta_id_regex = $fasta_id_regex || '>(.*)';
        $self->{ freader } = new FASTA::Reader({ filename => $fasta_file, id_regex => $fasta_id_regex });
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

    my @els = ();
    foreach my $line (@$lines) {
        my ($id,$gene_id,$chr,$strand,$gstart,$gstop,$start,$stop,$score) = $line =~ m/(.*),.*,.*,.*,(.*) \| Symbols: .* \| (.*):(.*)-(.*) (.*),(.*),(.*),(.*)/;
        push @els, {
            name => $id,
            gene_id => $gene_id,
            'chr' => $chr,
            strand => $strand eq 'FORWARD' ? q{+} : q{-},
            start => $gstart + $start,
            stop  => $gstart + $stop,
            score => $score,
        }
    }

    return $self->{ return }->{ csv }->{ srnas } = $self->make_output(\@els, $exp_id, $type);
}

sub make_output {
    my $self = shift;
    my $els  = shift;
    my $exp_id = shift;
    my $type = shift;

    my @lines = ();
    ### Generating output ...
    foreach my $el (@{ $els }) { ### [%]
        my $line = q{};
        my $id = $self->get_next_id;

        # check the type
        my $type_id = $self->add_type($type);
        $el->{ type_id } = $type_id;

        # add the exp_id
        $el->{ exp_id } = $exp_id;

        # get the abundance
        (my $abundance = $el->{ name }) =~ s/.*x(\d+)/$1/;
        $el->{ abundance } = $abundance;

        # get the sequence
        my $seq = undef;
        if (exists $self->{ freader }) {
            my $freader = $self->{ freader };
            $seq = substr(${ $freader->get_seq_ref($self->{ fasta_file }, $el->{ gene_id }) }, $el->{ start }, $el->{ stop }); 
        }

        # look up if the seq already is stored in the db
        my $seq_id = undef;
        if ($seq) {
            $seq_id = $self->add_seq($seq);
        }
        $el->{ seq_id } = $seq_id || 1;

        # quote for the DB
        my @e = map { $self->{ dbh }->quote($_) } @{ $el->{ elements } };

        my $undef = $self->{ dbh }->quote(undef);

        # make the output
        $line  = $id;
        $line .= "\t" . $el->{ name      };
        $line .= "\t" . $el->{ start     };
        $line .= "\t" . $el->{ stop      };
        $line .= "\t" . $el->{ strand    };
        $line .= "\t" . $el->{ seq_id    };
        $line .= "\t" . $el->{ score     };
        $line .= "\t" . $el->{ type_id   };
        $line .= "\t" . $el->{ abundance };
        $line .= "\t" . $undef;
        $line .= "\t" . $el->{ exp_id    };
        $line .= "\t" . $el->{ chr       };

        push @lines, $line;
    }

    return \@lines;
}

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
