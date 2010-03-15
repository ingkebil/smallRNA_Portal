#!/usr/bin/perl

################################################################################
# Check if miRNA has multiple exons
#
# Usage: ./GFFPrintFeature.pl inputfile.gff
################################################################################

use strict;
use warnings;
use Smart::Comments;

open(GFFFILE,'<' . $ARGV[0]);
my @lines = <GFFFILE>;
close GFFFILE;

my %features = ();
my %exons    = (); # key is parent, value is an array of exon IDs
my $exon     = 0; # followup number for the exons as they don't have an ID in the attr of the GFF file

LINE:
foreach my $line (@lines) { ### Building lookup table [%]
    next LINE if $line =~ m/^#/;   # skip comments
    next LINE if $line =~ m/^ *$/; # skip blank lines
    my ($seq_name, $source, $feature, $start, $stop, $score, $strand, $frame, $attributes) = split /\t/, $line;
    next LINE if $feature !~ m/^exon$|mirna$/i;

    my %split_attr = ();
    foreach my $attr (split(/;/, $attributes)) {
        $attr =~ s/\s?(.*)\s?/$1/; # remove trailing/leader whitespace
        $attr =~ s/(.*)#.*/$1/;    # remove EOL comments

        if ($attr =~ m/(.*)=(.*)/) { # name=value pair
            my $key    = $1;
            my $values = $2;

            my $value = $values;
            #        # leave out the second 'parent', should not be necessary, as this only happens with CDS
            #        VALUE:
            #        foreach my $v (split /,/, $values) {
            #            next VALUE if $value =~ m/protein/;
            #            $value = $v;
            #        }
            warn $values if $values =~ m/,/;

            $split_attr{ $key } = $value;
        }
    }

    my $ID = $split_attr{ 'ID' } || ++$exon;
    $features{ $ID } = {
        'seq_name' => $seq_name,
        'source'   => $source,
        'feature'  => $feature,
        'start'    => $start,
        'stop'     => $stop,
        'score'    => $score,
        'strand'   => $strand,
        'frame'    => $frame,
        'attr'     => \%split_attr
    };

    # make mapping parent->exon as well
    if ($feature eq 'exon') {
        my $parent = $split_attr{ Parent };
        $exons{ $parent } = [] if ! exists $exons{ $parent };
        push @{ $exons{ $parent } }, $exon;
    }
}

# the feature 'exon' is the last one in the hierarchy.
# So, we only need to count the parents of the exons.
my %exons_of = ();
EXON:
for my  $feature ( values %features ) { ### Counting exons [%]
    next EXON if $feature->{ feature } ne 'exon';

    my $parent = $feature->{ attr }->{ Parent };

    if (exists $features{ $parent }) {
        $exons_of{ $parent }++;
    }
}

# print the results!
use Data::Dumper;
RESULT:
while (my ($id, $count) = each %exons_of) { ### Checking results [%]
    next RESULT if $count <= 1;

    $features{ $id }->{ count } = $count;
    $features{ $id }->{ exons } = [];
    for my $exon_id (@{ $exons{ $id } }) {
        push @{ $features{ $id }->{ exons } }, $features{ $exon_id };
    }
    print Dumper $features{ $id };
}
