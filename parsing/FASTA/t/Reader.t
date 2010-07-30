use Test::More qw/no_plan/;

my $package = 'FASTA::Reader';
my $filename = 'test';
use_ok($package) or die;
can_ok($package, 'new');

my @lines = <DATA>;
my $r = $package->new({ filename => $filename, 'lines' => \@lines });

isa_ok($package, 'FASTA::Reader');

my $test1 =
'qwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwerty';
is(${ $r->get_seq_ref($filename => 'TEST1') }, $test1);

__DATA__

>TEST1
qwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwerty
qwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwerty
qwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwerty
qwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwerty
qwertyqwertyqwertyqwertyqwertyqwertyqwertyqwertyqwerty

>TEST2
azertyazertyazertyazertyazertyazertyazertyazertyazertyazertyazerty
azertyazertyazertyazertyazertyazertyazertyazertyazertyazertyazerty
azertyazertyazertyazertyazertyazertyazertyazertyazertyazertyazerty
azertyazertyazertyazertyazertyazertyazertyazertyazertyazertyazerty
azertyazertyazertyazertyazertyazertyazertyazertyazerty

