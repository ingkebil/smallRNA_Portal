package SRNA::Parseall;

use strict;
use warnings;
use DBI;
use Getopt::Long;
use File::Path qw/ make_path /;
use Data::Dumper;

our $dbh = DBI->connect('dbi:mysql:database=smallrna', 'kebil', 'kebil');

our $fasta_file_t = '"$cond_dir/$cond/$cond.unique.fas"'; # add the double quotes as these strings get evel'd lateron
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
        smallrna  => [ qw/ P+3h N N+3h FN FN2 C2 C3O3 C3h5 / ],
        # degradome => [ qw/ DFN D-N D-P D-P12 / ],
    };

    # run the Exp2sRNA script for the genome mapping (needs a gff and a fasta file)
    foreach my $srna_type (keys %$conds) {
        foreach my $cond (@{ $conds->{ $srna_type } }) {
            print "Parsing '$cond' ... \n";
            my $path = "/home/billiau/tmp/$srna_type/$cond/";
            make_path($path) if (!-d $path);

            my $exp_id = 0;
            if (!( $exp_id = &exists_exp($cond, $species_id))) {
                $exp_id = &add_exp($cond, '', $species_id);
            }

            my $fasta_file = eval($fasta_file_t); # get the variables filled in
            my $mapp_file  = eval($mapp_file_t);  # 

            # execute the parsing!
            print qq{perl GFF/Exp2sRNA.pm --experiment_id $exp_id --type $srna_type --path '$path' --fasta $fasta_file $mapp_file"\n};
            `perl GFF/Exp2sRNA.pm --experiment_id $exp_id --type $srna_type --path '$path' --fasta $fasta_file $mapp_file`;
            print "Importing sequences...";
            `mysql -u kebil -pkebil smallrna < '$path/sequences.sql'`;
            print "done\n";
            print 'Importing srnas...';
            `mysqlimport -u kebil -pkebil -L --fields-enclosed-by \\' smallrna '$path/srnas.csv'`;
            print "done\n";
        }
    }
}

sub add_exp {
    my $insert = $dbh->prepare('INSERT INTO `experiments` (name, description, species_id) VALUES (?, ?, ?)');
    exit(1) if ! $insert->execute( @_ );
}

sub exists_exp {
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

