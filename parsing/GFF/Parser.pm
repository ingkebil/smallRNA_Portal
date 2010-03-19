package GFF::Parser;

###########################################################################
# Provides a method to loop over a GFF file, do some basic administration and
# execute a callback per line
#
# Callback signature: callback({ elements => \@els, attributes => \@attr });
# If no callback if given, the @_ of above signature is returned.
#
###########################################################################

use strict;
use warnings;
use Smart::Comments;
use Data::Dumper;

sub new {
    my $inv   = shift;
    my $class = ref($inv) || $inv;
    my $self  = { par_lines => [], };
    bless $self, $class;
    if (scalar @_) { # if there are lines and possibly a callback, add them to $self
        #($self->{ gff_lines }) = @_; # we don't need to store this as this is the task of the caller
         $self->{ par_lines }  = $self->parse(@_);
    }

    return $self;
}

sub parse {
    my $self  = shift;
    my $lines = shift || warn "No lines to parse!\n";
    my $lines_cb = shift || sub { return wantarray ? @_ : $_[0] };

    my $return = [];
    my $return_cb = shift || sub { 
        my $par_line = shift;
        if ($par_line) { # skip empty results
            push @{ $return }, $par_line; 
        }
    };

    LINE:
    foreach my $line (@{ $lines}) { ### Parsing GFF [%]
        next LINE if $line =~ m/^#/;   # skip comments
        next LINE if $line =~ m/^ *$/; # skip blank lines
        my (@els) = split /\t/, $line;
        if (scalar @els != 9) {
            warn "Does not seem to be GFF? Skipping line: '$line'.";
            next LINE;
        }
        my $attributes = pop @els;

        my %split_attr =
            grep { /.+/ }     # only keep the elements that have some content
            map { chomp; $_ } # remove trailing whitespace
            split /;|=/,      # split the attr
            $attributes;

         &$return_cb(
            &$lines_cb(
                { elements => \@els, attributes => \%split_attr }
            )
        );
    }

    return $return;
}

1;
