#!/usr/bin/perl

################################################################################
# Check if numbers of attributes in experiment gff files are followup numbers
#
#
# Usage: ./GFFattributeCheck.pl inputfile.gff
################################################################################

use strict;
use warnings;
use Smart::Comments;

open(GFFFILE,'<' . $ARGV[0]);
my @lines = <GFFFILE>;
close GFFFILE;

my %count_of = (); # feature count

print 'Counting .. ';
LINE:
foreach my $line (@lines) { ### Processing [%]
    next LINE if $line =~ m/^#/;   # skip comments
    next LINE if $line =~ m/^ *$/; # skip blank lines
    my ($seq_name, $source, $feature, $start, $stop, $score, $strand, $frame, $attributes) = split /\t/, $line;

    $attributes =~ m/P_(\d*)_x(\d*)/;

    my $count = $count_of{ $1 }->{ count } || 0;
    $count++;
    $count_of{ $1 } = { count => $count, abundance => $2 };
}
print "Done.\n";

foreach my $followup ( sort { $a <=> $b } keys %count_of ) {
    print $followup . '=>' . $count_of{ $followup }->{ count } . q{ } . $count_of{ $followup }->{ abundance } . "\n";
}
