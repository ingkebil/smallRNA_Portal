package TPlot::CSV2sRNA;

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;
use DBI;

use Settings q/:DB/;
use FASTA::Reader;
use SRNA::DBAbstract;

&run() unless caller;

sub run {
    my $csvfile = q{};
    my ($exp_id, $species_id) = 0;
    my ($path, $fasta_file, $fasta_id_regex, $chr_fasta) = q{};

    my $opts = GetOptions(
        'experiment_id=i' => \$exp_id,
        'path:s' => \$path,
        'chrfasta:s' => \$chr_fasta,
        'speciesid:i' => \$species_id,
    );

    pod2usage(2) if (! $exp_id && ! $species_id && !$ARGV[0]);

    print "Reading CSV $ARGV[0] ... ";
    open F, '<', $ARGV[0] or die "$ARGV[0] not found!\n";
    my @lines = <F>; ### Reading GFF [%]
    close F;
    print "done.\n";
    my $exp2srna = __PACKAGE__->new({ chr_fasta => $chr_fasta });

    print 'Parsing CSV... ';
    $exp2srna->run_parser(\@lines, $exp_id, $species_id);
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
    my $chr_fasta = $s->{ chr_fasta };
    my $user = $s->{ user } || USER;
    my $pass = $s->{ pass } || PASS;
    my $db   = $s->{ db   } || DB;

    my $class = ref $inv || $inv;

    my $dbh = DBI->connect('dbi:mysql:database='. $db, $user, $pass) or die "Could not connect to DB\n";
    my $seqs   = new SRNA::DBAbstract({ dbh => $dbh, table => 'sequences' });

    my $self = {
        dbh    => $dbh,
        seqs   => $seqs,
        chr_fasta => $chr_fasta,
        parsed => {},
        return => { csv => { srnas => [], sequences => [], types => [] } },
    };

    return bless $self, $class;
}

sub run_parser {
    my $self = shift;
    my ($lines, $exp_id, $species_id) = @_;

    ## parse the file into a workable structure
    # {
    #     start => [
    #        { ID, start, stop, seq }
    #     ],
    # }
    my $degrs = {};
    my $ref_num = 0;
    my $ref_seq_fl = 0;
    my $ref_seq = q{};
    my $ref_id = q{};

    LINE:
    foreach my $line (@$lines) {
        for ($line) {
            /^(\d+)/ && do {
                $ref_num = $1; # get the start position
                $ref_seq_fl = 1; # next line is the ref seq, set the flag!
                next LINE;
            };
            /.*/ && do { # just check the ref_seq_fl, or fall through
                if ($ref_seq_fl) {
                    # get the ref seq
                    my ($ref_seq_spl, $ref_id_spl) = split /\s+/, $line;
                    $ref_seq .= $ref_seq_spl;
                    $ref_id = $ref_id || $ref_id_spl;
                    $ref_seq_fl = 0; # set the flag back to false
                    next LINE;
                }
            };
            /^$/ && do { # skip me
            };
            /.+/ && do {
                my ($start, $stop, $score) = 0;
                my ($degr_id, $seq) = q{};

                my @line_spl = split //, $line; # make the line into an array
                CHAR:
                foreach my $l (@line_spl) {
                    do { $start++; next CHAR } if $l eq q{ }; # skip and count the amount of whitespace
                    last CHAR;
                }
                ($seq, $degr_id, $score) = # get the seq and the id
                    map { chomp; $_} # remove \n from els
                    grep /.+/, # remove empty els
                    split /\t|\s/, # split the line on multiple whitespace and tabs
                    $line;
                $degr_id .= " $score";
                $start += $ref_num;
                $stop   = length($seq) + $start - 1;

                # put the results into a nice structure
                my $struct = { id => $degr_id, start => $start, stop => $stop, seq => $seq, score => $score };
                $degrs->{ $start } = [] if ! exists $degrs->{ $start };
                push @{ $degrs->{ $start } }, $struct;
            };
        }
    }

    %{ $self->{ inter_parsed } } = %$degrs;

    ## convert the workable structure to an array of degr
    my $parsed = [];
    my $ids = {}; # we need a structure to rename equal-named ids: id => followup_num
    foreach my $start_stop (sort { $a <=> $b } keys %$degrs) {
        foreach my $degr (@{ $degrs->{ $start_stop } }) {
            my $new_degr = {};
            next if ! defined $degr; # skip those we've 'removed'
            %$new_degr = %$degr;
            $ids->{ $degr->{ id } }++;# if ! exists $ids->{ $degr->{ id } };
            my $id_nr = $ids->{ $degr->{ id } };
            my ($id, $expr) = split /\s+/, $degr->{ id };
            $new_degr->{ id } = $id.'_'.$id_nr.'_x'.$expr;

            if ($degr->{ stop } % 100 == 0) { # owla, looks like this degr is ending on a split
                my $end_degrs = $degrs->{ $degr->{ stop } + 1 };
                STOP:
                foreach my $end_degr (@$end_degrs) {
                    next STOP if ! defined $end_degr; # skip those who've been removed
                    next STOP if $end_degr->{ id } ne $degr->{ id };
                    $new_degr->{ stop  } = $end_degr->{ stop };
                    $new_degr->{ seq   } = $degr->{ seq } . $end_degr->{ seq };

                    undef $end_degr; # remove the degr!
                    last STOP;
                }
            }

            ## look up the seq
            my $seq_id =  $self->{ seqs }->get_id('seq' => $new_degr->{ seq })
                    || $self->{ seqs }->add({ seq => $new_degr->{ seq } });
            $new_degr->{ seq_id } = $seq_id;

            ## look up the chromosome
            ## adjust the start pos of the smallread
            my ($acc, $model) = split /\./, $ref_id;
            my $chrom = $self->{ dbh }->selectrow_hashref('SELECT chromosome_id, start FROM annotations WHERE accession_nr = ? AND model_nr = ?', { }, ($acc, $model));
            if (defined $chrom && scalar $chrom) {
                $new_degr->{ chrom_id } = $chrom->{ chromosome_id };
                $new_degr->{ genome_start } = $chrom->{ start } + $new_degr->{ start };
                $new_degr->{ genome_stop  } = $chrom->{ start } + $new_degr->{ stop  };
            }

            ## add the exp_id
            $new_degr->{ exp_id } = $exp_id;

            ## calc eventual mismatches
            if ($self->check_mismatch($new_degr, $ref_seq)) {
                print Dumper $new_degr;
            }

            push @$parsed, $new_degr;
        }
    }

    $self->{ parsed } = $parsed;
    # print Dumper $parsed;

    # print Dumper $self->make_output();

    $self->{ return }->{ csv }->{ srnas } = $self->make_output();
    $self->{ return }->{ csv }->{ sequences } = $self->{ seqs }->get_new_rows_CSV('id', 'seq'); 

    return $parsed;
}

sub check_mismatch {
    my $self = shift;
    my $srna = shift;
    my $ref_seq = shift;

    my @ref_seq_spl = split //, $ref_seq;
    my @srna_seq_spl = split //, $srna->{ seq };

    my $mm_num = 0; # number of mismatches
    my $mm_seq = q{}; # the seq with mismatches highlighted
    for (my $i = $srna->{ start }; $i <= $srna->{ stop }; $i++) {
        my $i_srna = $i - $srna->{ start };
        if ($ref_seq_spl[ $i - 1 ] ne $srna_seq_spl[ $i_srna ]) {
            $mm_num++;
            $mm_seq .= lc($srna_seq_spl[ $i_srna ]);
        }
        else {
            $mm_seq .= $srna_seq_spl[ $i_srna ];
        }
    }

    $srna->{ mm_seq } = $mm_seq;
    return $srna->{ mm_num } = $mm_num;
}

sub make_output {
    my $self = shift;

    my @e = ();
    foreach my $srna (@{ $self->{ parsed } }) {
        my $s = {};
        foreach my $key (keys %$srna) {
            $s->{ $key } = $self->{ dbh }->quote($srna->{ $key });
        }
        push @e, $s;
    }

    my $undef = $self->{ dbh }->quote(undef);

    my @result = ();
    foreach my $srna ( @e ) {
        my $line = $undef;                   # id
        $line .= "\t" . $srna->{ id };       # name
        $line .= "\t" . $srna->{ genome_start };    # start 
        $line .= "\t" . $srna->{ genome_stop  };    # stop
        $line .= "\t" . '+';                 # strand
        $line .= "\t" . $srna->{ seq_id };   # seq_id
        $line .= "\t" . $srna->{ score };    # score
        $line .= "\t" . 2;                   # type id
        $line .= "\t" . $undef;              # abundance
        $line .= "\t" . $undef;              # norm abundance
        $line .= "\t" . $srna->{ exp_id };   # exp id
        $line .= "\t" . $srna->{ chrom_id }; # chr id
        push @result, $line;
    }

    return \@result;
}

1;

__END__
