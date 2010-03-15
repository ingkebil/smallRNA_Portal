#!/usr/bin/perl

use strict;
use warnings;
use Smart::Comments;

my %bin = ();
my $line_count = 0;
my $total_len  = 0;

open (F, '<', $ARGV[0]) || die "Cannot open $ARGV[0]\n";
LINE:
foreach my $line (<F>) { ### Processed [%]
    next LINE if $line =~ m/^>/;

    $bin{ length $line }++;

    $total_len += length $line;
    $line_count++;
}

map { print $_ . ' => ' . $bin{ $_ } ."\n" } sort keys %bin;
print 'AVG: ' . ( $total_len / $line_count ) . "\n";
