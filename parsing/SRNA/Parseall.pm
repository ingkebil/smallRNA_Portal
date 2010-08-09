package SRNA::Parseall;

use strict;
use warnings;
use DBI;
use Getopt::Long;
use Pod::Usage;
use File::Path qw/ make_path /;
use Settings q/:DB/;
use Data::Dumper;

our $dbh = DBI->connect('dbi:mysql:database='.DB, USER, PASS);

my %settings = (
    arath => {
        dirs => {
            fasta_file => '"$cond_dir/$cond/$cond.unique.fas"', # add the double quotes as these strings get eval'd lateron
            mapp_file  => '"$mapp_dir/$cond/tair9/${cond}_on_genome.100.gff"',
        },
        conds => {
            smallrna  => [ qw/ P P+3h N N+3h FN FN2 C2 C303 C3h5 / ],
#            degradome => [ qw/ DFN D-N D-P D-P12 / ],
        },
    },
    medtr => {
        dirs => {
            fasta_file => '"$cond_dir/$cond/sequences/$cond.unique.fas"', # add the double quotes as these strings get eval'd lateron
            mapp_file  => '"$mapp_dir/$cond/evaluation/mt3/${cond}_on_mt3.100.gff"',
        },
        conds => {
            smallrna => [ qw/ GDN-1 GDN-2 / ],
            degradome => [ qw/ GDN-3 GDN-4 / ],
        },
    }
);

&run() unless caller();

sub run {
    my ($species_id, $moist_run) = 0;
    my ($species_name, $chr_fasta) = q{};

    my $opts = GetOptions(
        'speciesid:i' => \$species_id,
        'speciesname:s' => \$species_name,
        'chrfasta:s' => \$chr_fasta,
        'moist-run' => \$moist_run,
    );

    my $cond_dir = $ARGV[0];
    my $mapp_dir = $ARGV[1];

    pod2usage(2) if (! $species_id && ! $species_name);

    ($ARGV[0] && $ARGV[1]) || pod2usage(3);

    if (! $species_id) {
        if (! ($species_id = &select_species_id($species_name))) {
            die "Species '$species_name' not found in db!\n";
        }
    }
    if (! $species_name) {
        if (! ($species_name = &select_species_name($species_id))) {
            die "Species '$species_id' not found in db!\n";
        }
    }

    my $conds = $settings{ $species_name }->{ conds };
    my $dirs  = $settings{ $species_name }->{ dirs  };

    # run the Exp2sRNA script for the genome mapping (needs a gff and a fasta file)
    foreach my $srna_type (keys %$conds) {
        foreach my $cond (@{ $conds->{ $srna_type } }) {
            print "Parsing '$cond' ... \n";
            my $path = "/home/billiau/tmp/$species_name/$srna_type/$cond/";
            make_path($path) if (!-d $path);

            my $exp_id = 0;
            if (!( $exp_id = &select_exp($cond, $species_id))) {
                $exp_id = &add_exp($cond, $species_id, '');
            }

            my $fasta_file = eval($dirs->{ fasta_file }); # get the variables filled in
            my $mapp_file  = eval($dirs->{ mapp_file  }); # 

            # execute the parsing!
            my @prog = ("perl","GFF/Exp2sRNA.pm","--experiment_id","$exp_id","--type","$srna_type","--path","$path","--fasta","$fasta_file");
            if ($chr_fasta) {
                push @prog, ("--chrfasta", "$chr_fasta");
            }
            push @prog, ("--speciesid","$species_id", "$mapp_file");
            print join q{ }, @prog;
            system(@prog);
            if ($? == -1) {
                die "Failed to execute: $!\n";
            }
            elsif ($? & 127) {
                die sprintf "Child died with signal %d, %s coredump\n",
                ($? & 127), ($? & 128) ? 'with' : 'without';
            }
            elsif ($? >> 8 != 0) {
                die sprintf "Child exited with value %d\n", $? >> 8;
            }
            if (! $moist_run ) {
                my $user = USER; my $pass = PASS; my $db = DB;
                foreach my $outtype ( ('types', 'sequences', 'chromosomes', 'srnas', 'mismatches') ) {
                    my $count = `find $path -name '$outtype*csv' | wc -l`;
                    print "Importing $count of $outtype...";
                    foreach my $i (1 .. $count) {
                        `mysqlimport -u $user -p$pass -L -i --fields-enclosed-by \\' $db '$path/$outtype.$i.csv'`;
                    }
                    print "done\n";
                }
            }
        }
    }
}

sub add_exp {
    my $insert = $dbh->prepare('INSERT INTO `experiments` (name, species_id, description) VALUES (?, ?, ?)');
    die "Failed to insert the experiment id for " . join q{','}, @_ . '.' if ! $insert->execute( @_ );

    return &select_exp;
}

sub select_exp {
    @_ = @_[0,1];
    my $rs = $dbh->selectrow_arrayref(q{ SELECT id FROM `experiments` WHERE name = ? AND species_id = ? }, undef, @_ );

    if (! defined $rs) {
        return undef;
    }
    return $rs->[0];
}

sub select_species_id {
    my $rs = $dbh->selectrow_arrayref(q{ SELECT id FROM `species` WHERE name = ? }, undef, ( $_[0] ) );

    if (! defined $rs) {
        return undef;
    }
    return $rs->[0];
}

sub select_species_name {
    my $rs = $dbh->selectrow_arrayref(q{ SELECT short_name FROM `species` WHERE id = ? }, undef, ( $_[0] ) );

    if (! defined $rs) {
        return undef;
    }
    return $rs->[0];
}
1;

__END__

=head1 SYNOPSIS

Usage: SRNA::Parseall [options] <cond_dir> <mapp_dir>

  <cond_dir>: a directory with FASTA files.
  <mapp_dir>: a directory with GFF files. 

  Both directories are the starting point of traversal according to a certain pattern. You can change the pattern in the source code.

  For each file met, GFF::Exp2sRNA.pm is invoked. Make sure GFF::Exp2sRNA is in your path!

  Options:
    --speciesid <id>: The ID of the species as provided in the DB, table 'species'.
    --chrfasta <file>: The FASTA file with the chromosomes for the abovementioned species.
    --moist-run: Don't import the generated CSV files, just run the script for all conditions. This will still create entries for the experiments in the DB!
  
