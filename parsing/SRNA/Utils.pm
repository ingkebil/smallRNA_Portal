package SRNA::Utils;

use Exporter qw/import/;
our @EXPORT_OK = qw/ promptUser /;
our %EXPORT_TAGS = ( ALL => [ @EXPORT_OK ] );

sub promptUser {
   my ($promptString,$defaultValue) = @_;

   if ($defaultValue) {
      print $promptString, "[", $defaultValue, "]: ";
   } else {
      print $promptString, ": ";
   }

   $| = 1;               # force a flush after our print
   $_ = <STDIN>;         # get the input from STDIN

   # remove the newline character from the end of the input the user
   # gave us.
   chomp;

   if ("$defaultValue") {
      return $_ ? $_ : $defaultValue;    # return $_ if it has a value
   } else {
      return $_;
   }
}

1;

__END__

=head1 SYNOPSIS

Used mainly in the test scripts to ask for username and password to connect to the database

=head1 METHODS

=head2 promptUser

=head1 AUTHOR

Kenny Billiau

