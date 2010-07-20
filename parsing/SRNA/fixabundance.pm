#!/usr/bin/perl

package SRNA::fixabundance;

use strict;
use warnings;
use DBI;
use Data::Dumper;

&run() unless caller();

sub run {
    my $dbh = DBI->connect('dbi:mysql:smallrna', 'kebil', 'kebil');

    my $rs = $dbh->selectall_arrayref(q{SELECT abundance, id, name FROM srnas}, { Slice => {} });
    my $sth = $dbh->prepare(q{UPDATE srnas SET abundance = ? WHERE id = ?});

    foreach my $r (@$rs) {
        (my $new_abun = $r->{ name }) =~ s/.*x(\d+)/$1/;

        if ($new_abun != $r->{ abundance }) {
            print "Changing: $r->{id} from $r->{abundance} to $new_abun\n";
            $sth->execute( ($new_abun, $r->{ id }) );
        }
    }

}

1;

__END__
