use Test::More 'no_plan';

my $package = 'GFF::Exp2sRNA';
use_ok($package) or exit;
can_ok($package, 'run');
can_ok($package, 'new');
can_ok($package, 'run_parser');
can_ok($package, 'seq_sql_adder');
can_ok($package, 'type_sql_adder');

__DATA__
