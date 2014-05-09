#!/usr/bin/perl
package SRNA::Smapsrna;

use strict;
use warnings;
use DBI;
use Smart::Comments;
use Data::Dumper;
use Settings qw/:DB/;

&run(@ARGV) unless caller();

sub run {
    my $poll = shift || 1000;
    my $user = shift || USER;
    my $pass = shift || PASS;
    my $db   = shift || DB;

    my $dbi = DBI->connect('dbi:mysql:database='.$db, $user, $pass);

    my $max_id = $dbi->selectrow_arrayref(
        'SELECT max(id) FROM annotations')->[0];

    foreach my $i (1 .. $poll) { # count until $poll
        my $rid      = int(rand($max_id));
        my $annot    = $dbi->selectrow_arrayref(
            'SELECT id, start, stop, strand, chromosome_id FROM annotations WHERE id = ?',
            undef, ($rid));
        my $srna_ids = &rm_subarrayref($dbi->selectall_arrayref(
            'SELECT id FROM srnas 
            WHERE start >= ?
            AND stop <= ?
            AND strand = ? AND chromosome_id = ? ',
            undef, @{$annot}[1..4]
        ));

        my $mappings = &rm_subarrayref($dbi->selectall_arrayref(
            'SELECT srna_id FROM mappings
            WHERE annotation_id = ?',
            undef, $annot->[0]
        ));

        print $annot->[0], "\t", scalar @$srna_ids, "\t", scalar @$mappings;
        if (scalar @$srna_ids == 0 || scalar @$mappings == 0) {
            if (scalar @$srna_ids == 0 && scalar @$mappings == 0) {
                print "\tZ"; # zero matches
            }
            else {
                print "\tD"; 
            }
        }
        elsif ((scalar @$srna_ids == scalar @$mappings)
            || (scalar @$srna_ids % scalar @$mappings == 0)) {

            my $diff = scalar @$srna_ids / scalar @$mappings;
            my @sorted_srna_ids = sort @$srna_ids;
            my @sorted_mappings = sort @$mappings;

            print "\tC";

            CHECK:
            for (my $j = 0; $j < scalar @sorted_mappings; $j++) {
                if ($sorted_srna_ids[$j * $diff] != $sorted_mappings[$j]) {
                    print "\tD\t";
                    print $sorted_srna_ids[$j * $diff], "\t", $sorted_mappings[$j];
                    last CHECK;
                }
            }
        }
        else {
            print "\t?";
        }
        print "\n";
    }
}

sub rm_subarrayref {
    my $in = shift;
    my @out = map { $_->[0]; } @$in;
    return \@out;
}

1;

__END__

Program to test if mapping was done correctly by testing 1000 random
annotations' mapping.
