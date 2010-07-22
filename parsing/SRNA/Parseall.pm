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

our $fasta_file_t = '"$cond_dir/$cond/$cond.unique.fas"'; # add the double quotes as these strings get eval'd lateron
our $mapp_file_t  = '"$mapp_dir/$cond/tair9/${cond}_on_genome.100.gff"';

&run() unless caller();

sub run {
    my ($source_id, $species_id) = 0;
    my ($species_name, $source_name) = q{};

    my $opts = GetOptions(
        'sourceid:i' => \$source_id,
        'sourcename:s' => \$source_name,
        'speciesid:i' => \$species_id,
        'speciesname:s' => \$species_name,
    );

    my $cond_dir = $ARGV[0];
    my $mapp_dir = $ARGV[1];

    pod2usage(2) if (! $source_id && ! $source_name);
    pod2usage(2) if (! $species_id && ! $species_name);

    ($ARGV[0] && $ARGV[1]) || pod2usage(3);

    my $conds = {
        smallrna  => [ qw/ P P+3h N N+3h FN FN2 C2 C303 C3h5 / ],
        #degradome => [ qw/ DFN D-N D-P D-P12 / ],
    };

    # run the Exp2sRNA script for the genome mapping (needs a gff and a fasta file)
    foreach my $srna_type (keys %$conds) {
        foreach my $cond (@{ $conds->{ $srna_type } }) {
            print "Parsing '$cond' ... \n";
            my $path = "/home/billiau/tmp/$srna_type/$cond/";
            make_path($path) if (!-d $path);

            my $exp_id = 0;
            if (!( $exp_id = &select_exp($cond, $species_id))) {
                $exp_id = &add_exp($cond, $species_id, '');
            }

            my $fasta_file = eval($fasta_file_t); # get the variables filled in
            my $mapp_file  = eval($mapp_file_t);  # 

            # execute the parsing!
            print qq{perl GFF/Exp2sRNA.pm --experiment_id $exp_id --type $srna_type --path '$path' --fasta '$fasta_file' '$mapp_file'\n};
            system("perl","GFF/Exp2sRNA.pm","--experiment_id","$exp_id","--type","$srna_type","--path","$path","--fasta","$fasta_file","$mapp_file");
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
            foreach my $outtype ( ('sequences', 'types', 'srnas') ) {
                print "Importing $outtype...";
                $user = USER; $pass = PASS; $db = DB;
                `mysqlimport -u $user -p$pass -L --fields-enclosed-by \\' $db '$path/$outtype.csv'`;
                print "done\n";
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

1;

__END__

=head1 SYNOPSIS

Usage: SRNA::Parseall [options] <cond_dir> <mapp_dir>

  <cond_dir>: a directory with FASTA files.
  <mapp_dir>: a directory with GFF files. 

  Both directories are the starting point of traversal according to a certain pattern. You can change the pattern in the source code.

  For each file met, GFF::Exp2sRNA.pm is invoked. Make sure GFF::Exp2sRNA is in your path!

  Options:
    --sourceid <id> : The ID the source as provided in the DB, table 'sources'.
    --speciesid <id>: The ID of the species as provided in the DB, table 'species'.
  
