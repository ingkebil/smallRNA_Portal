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

    print 'Reading CSV ... ';
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
    my $chroms = new SRNA::DBAbstract({ dbh => $dbh, table => 'chromosomes' });

    my $self = {
        dbh    => $dbh,
        chroms => $chroms,
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
    #     stop => [
    #        { ID, start, stop, seq }
    #     ]
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
            /.*/ && do {
                if ($ref_seq_fl) {
                    # get the ref seq
                    my ($ref_seq_spl, $ref_id_spl) = split /\s+/, $line;
                    $ref_seq .= $ref_seq_spl;
                    $ref_id = $ref_id || $ref_id_spl;
                    $ref_seq_fl = 0; # set the flag back to false
                    next LINE;
                }
            };
            /^$/ && do { };
            /.+/ && do {
                my ($start, $stop) = 0;
                my ($degr_id, $seq) = q{};

                my @line_spl = split //, $line; # make the line into an array
                CHAR:
                foreach my $l (@line_spl) {
                    do { $start++; next CHAR } if $l eq q{ }; # skip and count the amount of whitespace
                    last CHAR;
                }
                ($seq, $degr_id) = # get the seq and the id
                    map { chomp; $_} # remove \n from els
                    grep /.+/, # remove empty els
                    split /\t|\s{2,}/, # split the line on multiple whitespace and tabs
                    $line;
                $start += $ref_num;
                $stop   = length($seq) + $start - 1;

                # put the results into a nice structure
                my $struct = { id => $degr_id, start => $start, stop => $stop, seq => $seq };
                $degrs->{ $start } = [] if ! exists $degrs->{ $start };
                push @{ $degrs->{ $start } }, $struct;
            };
        }
    }

    %{ $self->{ parsed } } = %$degrs;

    ## convert the workable structure to an array of degr
    my $parsed = [];
    my $ids = {}; # we need a structure to rename equal-named ids 
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
                    next STOP if $end_degr->{ id } ne $degr->{ id };
                    $new_degr->{ stop  } = $end_degr->{ stop };
                    $new_degr->{ seq   } = $degr->{ seq } . $end_degr->{ seq };

                    undef $end_degr;
                    last STOP;
                }
            }
            push @$parsed, $new_degr;
        }
    }

    return $parsed;
}

1;

__END__
