use Test::More 'no_plan';

use Data::Dumper;
use SRNA::Utils qw/ promptUser /;

my $package = 'SRNA::Seq2FASTA';
use_ok($package) or exit;
can_ok($package, 'new');

__DATA__

TODO: still need to actually make the tests here
