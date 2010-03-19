#!/usr/bin/perl

################################################################################
# List how features refer to other with the 'Parent' attribute.
#
# Usage: ./GFFPrintFeature.pl inputfile.gff
################################################################################

use strict;
use warnings;
use Smart::Comments;

open(GFFFILE,'<' . $ARGV[0]);
my @lines = <GFFFILE>;
close GFFFILE;

my %count_of = (); # end result; hash of features. key is feature name, value is a hash. This hash consists of the names of the features of the parents as key and the count as the value.
my %rcount_of = (); # end result; same as above, but first key is the parent, second their children. Seemed more logical to wrap my head around.
my %feature_of = (); # intermediate result; hash of features. key is ID, values is the feature type.
my %parents_of = (); # intermediate result; hash of parents. key is the feature type, values are the parent IDs.

LINE:
foreach my $line (@lines) { ### Building lookup table [%]
    next LINE if $line =~ m/^#/;   # skip comments
    next LINE if $line =~ m/^ *$/; # skip blank lines
    my ($seq_name, $source, $feature, $start, $stop, $score, $strand, $frame, $attributes) = split /\t/, $line;
    my @split_attr = split /;/, $attributes;

    foreach my $attr (@split_attr) {
        $attr =~ s/\s?(.*)\s?/$1/; # remove trailing/leader whitespace
        $attr =~ s/(.*)#.*/$1/;    # remove EOL comments

        if ($attr =~ m/(.*)=(.*)/) { # name=value pair
            my $key    = $1;
            my $values = $2;
            KEY:
            for ($key) {
                $key eq 'ID' && do { # store ID => 'feature'
                    if (exists $feature_of{ $values }) {
                        warn "$key has multiple entries!";
                    }
                    $feature_of{ $values } = $feature;
                    next KEY;
                };
                $key eq 'Parent' && do { # store the parent_IDs
                    $parents_of{ $feature } = [] if ! exists $parents_of{ $feature };
                    foreach my $value (split /,/, $values) {
                        push @{ $parents_of{ $feature } }, $value;
                    }
                    next KEY;
                };
            }
        }
    }
}

while (my ($feature, $parents) = each %parents_of) { ### Processing Child-Parent relationship [%]
    $count_of{ $feature } = {} if ! exists $count_of{ $feature };
    my $counts = $count_of{ $feature };

    # lookup the feature type of the parent
    foreach my $parent (@{ $parents }) {
        my $parent_feature_type = $feature_of{ $parent };

        $rcount_of{ $parent_feature_type } = {} if ! exists $rcount_of{ $parent_feature_type };

        $rcount_of{ $parent_feature_type }->{ $feature }++;
        $counts->{ $parent_feature_type }++;
    }
}

use Data::Dumper;
print "CHILDREN -> PARENTS\n";
print Dumper \%count_of;
print "PARENTS -> CHILDREN\n";
print Dumper \%rcount_of;
