#!/usr/bin/perl

use strict;
use warnings;

open(GFFFILE,'<' . $ARGV[0]);

my %count_of = (); 
#my $i = 0;

my @lines = <GFFFILE>;

LINE:
foreach my $line (@lines) {
    # first, check if we find the word transcriptId or proteinId
    #print $line;
    my @split_line = split /\t/, $line;
    my @split_attr = split /;/, $split_line[8];
    my $id_found = 0;
    foreach my $attr (@split_attr) {
        $attr =~ s/\s?(.*)\s?/$1/;
        #print $attr . ' : ';
        if ($attr =~ m/(proteinId|transcriptId)/) {
            #print "matched\n";
            my @split_attr = split /\s+/, $attr;
            my $count = 1;
            if (exists $count_of{ $split_attr[1] }) {
                $count = $count_of{ $split_attr[1] } + 1;
            }
            #print $split_attr[1] . '=' . $count . "\n";
            $count_of{ $split_attr[1] } = $count;
            #print $count_of{ $split_attr[1] } . '=' . $count . "\n";
            $id_found = 1;
        }
        else {
            #print "not matched\n";
        }
    }
#    if (!$id_found) {
#        print $line . "\n";
#    }
#    last LINE if $i == 1;
#    $i++;
}

#print "The counts:\n";
#foreach my $id (keys %count_of) {
#    print $id . '=' . $count_of{$id} . "\n";
#}

# some analysis

# how far are the Id's apart.
my $summed_gaps = 0;
my $min_gap = 1000000;
my $max_gap = 0;

my $previous_id = 100000;
GAP:
foreach my $id (sort keys %count_of) {
    next GAP if $id == $previous_id;
    my $gap = $id - $previous_id;
    if ($min_gap > $gap) {
        $min_gap = $gap;
    }
    if ($max_gap < $gap) {
        $max_gap = $gap;
    }
    $summed_gaps += $gap;
    $previous_id = $id;
}
print 'Avarange : ' . ($summed_gaps / keys %count_of) . "\n";
print 'Minimum  : ' . $min_gap . "\n";
print 'Maximum  : ' . $max_gap . "\n";
