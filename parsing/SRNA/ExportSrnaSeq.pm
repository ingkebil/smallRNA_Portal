#!/usr/bin/perl
package SRNA::ExportSrnaSeq;

use strict;
use warnings;
use DBI;
use Settings q/:DB/;
use Getopt::Long;
use Data::Dumper;

&run unless caller();

sub run {
    if (!$ARGV[0]) {
        die "Please provide one argument: the number of sRNAs to extract\n";
    }

    my $path = q{};
    my $args = GetOptions(
        'path:s' => \$path
    );

    my $dbi = DBI->connect('dbi:mysql:database='.DB, USER, PASS);

    my $srnas = $dbi->selectall_arrayref('SELECT * FROM srnas LIMIT '.$ARGV[0]);
    add_all('srnas', $srnas);

    foreach my $srna (@$srnas) {
        my $seq = $dbi->selectrow_arrayref('SELECT * FROM sequences WHERE id = '.$srna->[5]);
        add('sequences', $seq) if $seq;
        my $type = $dbi->selectrow_arrayref('SELECT * FROM types WHERE id = '.$srna->[7]);
        add('types', $type) if $type;
        my $experiment = $dbi->selectrow_arrayref('SELECT * FROM experiments WHERE id = '.$srna->[-2]);
        add('experiments', $experiment) if $experiment;
        my $chromosome = $dbi->selectrow_arrayref('SELECT * FROM chromosomes WHERE id = '.$srna->[-1]);
        add('chromosomes', $chromosome) if $chromosome;
        #my $mappings = $dbi->selectall_arrayref('SELECT * FROM mappings WHERE srna_id = '.$srna->{'id'});
        #add_all('mappings', $mappings) if $mappings;
        #my $annotations = $dbi->selectall_arrayref('SELECT * FROM annotations WHERE srna_id = '.$srna->{'id'});
        #add_all('mappings', $mappings) if $mappings;
    }

    while (my ($type, $data) = each %{ &get_all() }) {
        fprint("$path/$type.csv", join "\n", keys %$data); 
    }

}
 
sub fprint {
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

{
    my %data_of = ();

    sub add {
        my ($type, $data) = @_;

        my $d = join "\t", @$data;

        if (! exists($data_of{ $type }->{ $d })) {
            $data_of{ $type }->{ $d } = 1;
            return 1;
        }

        return 0;
    }

    sub add_all {
        my ($type, $data) = @_;

        foreach my $info (@$data) {
            add($type, $info);
        }
    }

    sub get_all {
        return \%data_of;
    }

}

1;

__END__

=head1 SYNOPSIS

Extracts the first x sRNAs from the DB with all the depending data from related tables. This is ideal to make a test DB. Presumes the target DB is empty. Takes the login information for the source DB from the Settings.pm.

Expects only one argument: the number of sRNAs to extract.
