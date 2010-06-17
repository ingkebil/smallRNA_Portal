package SRNA::Add_Experiment;

use strict;
use warnings;
use DBI;
use Getopt::Long;
use Pod::Usage;

&run() unless caller();

sub run {
    my ($name, $descr) = q{};
    my $species_id = 0;

    my $opts = GetOptions(
        'name=s' => \$name,
        'descr=s' => \$descr,
        'species_id:i' => \$species_id
    );

    pod2usage(2) if (!$name && !$descr && !$species_id);
    
    my $dbh = DBI->connect('dbi:mysql:database=smallrna', 'kebil', 'kebil');

    my $insert = $dbh->prepare('INSERT INTO `experiments` (name, description, species_id) VALUES (?, ?, ?)');
    exit(1) if ! $insert->execute( $name, $descr, $species_id );
}

__END__

=head1 SYNOPSIS

Usage: perl SRNA::Add_Experiment [options]

Options:
    --name: the short name for the experiment.
    --description: some enlightenment ;)
    --species_id: the id of the species in the DB.

