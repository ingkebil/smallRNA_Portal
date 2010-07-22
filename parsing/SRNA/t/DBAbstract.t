use Test::More 'no_plan';

use Data::Dumper;
use SRNA::Utils qw/ promptUser /;

my $package = 'SRNA::DBAbstract';
use_ok($package) or exit;
can_ok($package, 'new');

# prompt for username and pw to create a tmp db
my $user = &promptUser('User for DB', 'kebil');
my $pass = &promptUser('Password for DB', 'kebil');

# create tmp db
`echo 'CREATE DATABASE kebil_abstract_test' | mysql -u $user -p$pass`;
my $dbh = DBI->connect('dbi:mysql:database=kebil_abstract_test', $user, $pass, { ChopBlanks => 1, AutoCommit => 1 });
$dbh->do('CREATE TABLE IF NOT EXISTS `chromosomes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `length` int(11) NOT NULL,
  `species_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;');

# init the Abstraction object
my $chroms = new SRNA::DBAbstract({
        dbh => $dbh,
        table => 'chromosomes',
});

is($chroms->get_id('name', 'Chr1'), undef);
is($chroms->get_next_id, 1);
is($chroms->add({ name => 'Chr1', length => 20, species_id => 1 }), 2);
is($chroms->get_cur_id, 2);
is($chroms->get_id('name', 'Chr1'), 2);
is_deeply($chroms->get_new_rows, [
    { name => 'Chr1', length => 20, species_id => 1, id => 2 }
]);
is_deeply($chroms->get_new_rows_CSV, [
    { name => 'Chr1', length => 20, species_id => 1, id => 2 }
]);
is_deeply($chroms->get_new_rows_CSV('id', 'name', 'length', 'species_id'), [
    '2	Chr1	20	1',
]);

# destroy the tmp db
$dbh->do('DROP DATABASE `kebil_abstract_test`');

__DATA__


