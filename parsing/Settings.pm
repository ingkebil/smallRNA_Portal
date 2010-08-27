package Settings;

use strict;
use warnings;

use constant USER => 'kebil';
use constant PASS => 'kebil';
use constant DB   => 'smallrna_arath';

use Exporter qw/import/;
our @EXPORT_OK = qw/ USER PASS DB /;
our %EXPORT_TAGS = ( DB => [ @EXPORT_OK ] );
