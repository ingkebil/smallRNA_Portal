#!/usr/bin/perl

################################################################################
# List all distinct features ina GFF file. For each feature, list all it's
# different attributes and multivalued attributes.
#
# Usage: ./GFFPrintFeature.pl inputfile.gff
################################################################################

use strict;
use warnings;
use Smart::Comments;

open(GFFFILE,'<' . $ARGV[0]);
my @lines = <GFFFILE>;
close GFFFILE;

my %count_of = (); # feature count

LINE:
foreach my $line (@lines) { ### Processing [%]
    next LINE if $line =~ m/^#/;   # skip comments
    next LINE if $line =~ m/^ *$/; # skip blank lines
    my $counts = {}; 
    my ($seq_name, $source, $feature, $start, $stop, $score, $strand, $frame, $attributes) = split /\t/, $line;
    my @split_attr = split /;/, $attributes;

    if (defined $count_of{ $feature }) {
        $counts = $count_of{ $feature };
    }
    my $which_strand = $strand eq q{-} ? q{-} : q{+}; # what is this extra check for?
    $counts->{ $which_strand }++;
    $counts->{ count }++; # add the feature 
    $counts->{ attr  } = {} if ! defined $counts->{ attr  };
    $counts->{ mattr } = {} if ! defined $counts->{ mattr };

    foreach my $attr (@split_attr) {
        $attr =~ s/\s?(.*)\s?/$1/; # remove trailing/leader whitespace
        $attr =~ s/(.*)#.*/$1/;    # remove EOL comments

        if ($attr =~ m/(.*)=(.*)/) { # name=value pair
            $counts->{ attr }->{ $1 }++;
            my $values = $2;
            if ($values =~ m/,/) {
                $counts->{ mattr }->{ $values }++;
            }
        }
    }

    $count_of{ $feature } = $counts;
}

use Data::Dumper;
print Dumper \%count_of;
