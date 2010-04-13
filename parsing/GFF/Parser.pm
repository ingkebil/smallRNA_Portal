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

=head1
The constructor.
Invoke like:
=head2 new();
Will return a __PACKAGE__ object.

=head2 new(\@lines);
Will return a __PACKAGE__ object with the \@lines parsed into a @{ $self->{ par_lines } }.

=head2 new(\@lines, \&lines_callback);
Will return a __PACKAGE__ object with \@lines parsed and put through the \&lines_callback.
The parsed lines are available in @{ $self->par_lines } }.
The \&lines_callback should have { elements => \@els, attributes => \%attr_pairs } as signature.

=head2 new(\@lines, \&lines_callback | undef, \&return_callback);
Will return a __PACKAGE__ object with \@lines parsed and put through the \&lines_callback, if it exists.
Instead of putting the parsed lines by default into an array structure, each line is given to a return_callback who decised what to do with the parsed line. Parsed lines are not available through $self->{ par_lines }, unless the \&return_callback specifies this.
The \&return_callback has $line as signature. What the structure of $line is, is up to the lines_callback.

=cut
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

__END__


