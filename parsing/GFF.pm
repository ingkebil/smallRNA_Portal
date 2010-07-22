package GFF;

use constant CHR     => 0;
use constant SOURCE  => 1;
use constant FEATURE => 2;
use constant START   => 3;
use constant STOP    => 4;
use constant SCORE   => 5;
use constant STRAND  => 6;
use constant FRAME   => 7;

use Exporter qw/import/;
our @EXPORT_OK = qw/ CHR SOURCE FEATURE START STOP SCORE STRAND FRAME /;
our %EXPORT_TAGS = ( GFF_SLOTS => [ @EXPORT_OK ] );

1;

__END__

=head1 SYNOPSIS

Placeholder module for the GFF Constants

=head1 AUTHOR

Kenny Billiau

