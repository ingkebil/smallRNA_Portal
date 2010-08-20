use Test::More 'no_plan';

use Data::Dumper;
use SRNA::Utils qw/ promptUser /;
use FindBin qw/$Bin/;

my $package = 'SRNA::Smapsrna';
use_ok($package) or exit;
can_ok($package, 'run');

# init the tmp db
my $db   = &promptUser('DB', 'kebil_exp_test');
my $user = &promptUser('User for DB', 'kebil');
my $pass = &promptUser('Password for DB', 'kebil');
`echo 'CREATE DATABASE $db' | mysql -u $user -p$pass`;
`mysql -u $user -p$pass $db < $Bin/../../../db/schema.ddl`;

my @lines = <DATA>; # read from the bottom of this file, from __DATA__ on
my @sql = ();
foreach my $line (@lines) {
    push @sql, $line;
}

{
    ## dummy db
    use DBI;
    my $dbh = DBI->connect("dbi:mysql:database=$db", $user, $pass);
    foreach my $st (@sql) {
        next if $st =~ /^$/;
        $dbh->do($st);
    }
}

my @results = sort @{ SRNA::Smapsrna::run('~/tmp/', $user, $pass, $db) };
my @expected_unsort = (
    "2\t1",
    "3\t1",
    "4\t1",
    "5\t1",
    "3\t2",
    "4\t2",
    "5\t2",
    "7\t2",
    "3\t3",
    "4\t3",
    "7\t3",
    "3\t5",
    "4\t5",
    "7\t5",
    "4\t6",
    "9\t8",
    "10\t9",
    "10\t10"
);
my @expected = sort @expected_unsort;
is_deeply(\@results, \@expected);

# drop the db
`echo 'DROP DATABASE $db' | mysql -u $user -p$pass`;

__DATA__
INSERT INTO `sources` (`id`, `name`, `description`) VALUES (1, 'TAIR9', '');
INSERT INTO `species` (`id`, `full_name`, `short_name`, `NCBI_tax_id`) VALUES (1, 'Arabidopsis thaliana', 'arath', 3702);
INSERT INTO `types` (`id`, `name`) VALUES (1, 'smallrna'), (2, 'degradome');
INSERT INTO `experiments` (`id`, `name`, `description`, `species_id`, `internal`) VALUES (1, 'DFN', '', 1, 0);
INSERT INTO `chromosomes` (`id`, `name`, `length`, `species_id`) VALUES (1, 'Chr3', 23459830, 1);
INSERT INTO `sequences` (`id`, `seq`) VALUES (1, 'ATG');
INSERT INTO `annotations` (`id`, `accession_nr`, `model_nr`, `start`, `stop`, `strand`, `chromosome_id`, `type`, `species_id`, `seq`, `comment`, `source_id`) VALUES (1, 'AT3G53400', 1, 200, 500, '+', 1, 'mRNA', 1, 'ATG', '', 1), (2, 'AT4G30540', 1, 300, 777, '+', 1, 'mRNA', 1, 'ATG', '', 1), (3, 'AT1G20560', 1, 750, 800, '-', 1, 'mRNA', 1, 'ATG', '', 1), (4, 'AT1G06450', 1, 753, 801, '+', 1, 'mRNA', 1, 'ATG', '', 1), (5, 'AT2G19020', 1, 754, 780, '+', 1, 'mRNA', 1, 'ATG', '', 1), (6, 'AT3TE67050', 1, 754, 770, '+', 1, 'transposable_element', 1, 'ATG', '', 1), (7, 'AT4G31240', 2, 755, 800, '-', 1, 'mRNA', 1, 'ATG', '', 1), (8, 'AT5TE40600', 1, 1000, 1100, '-', 1, 'transposable_element', 1, 'ATG', '', 1), (9, 'AT5TE49785', 1, 1000, 1200, '+', 1, 'transposable_element', 1, 'ATG', '', 1), (10, 'AT5G38020', 1, 3000, 9000, '-', 1, 'mRNA', 1, 'ATG', '', 1);
INSERT INTO `srnas` (`id`, `name`, `start`, `stop`, `strand`, `sequence_id`, `score`, `type_id`, `abundance`, `normalized_abundance`, `experiment_id`, `chromosome_id`) VALUES (1, 'P_701714_x1', 754, 776, '+', 1, 100, 1, 1, 0, 1, 1), (2, 'P_498551_x1', 755, 778, '+', 1, 100, 1, 1, 0, 1, 1), (3, 'P_237009_x5', 762, 785, '+', 1, 100, 1, 5, 0, 1, 1), (4, 'P_409085_x2', 771, 804, '+', 1, 100, 1, 2, 0, 1, 1), (5, 'P_107660_x1', 774, 797, '+', 1, 100, 1, 1, 0, 1, 1), (6, 'P_97981_x1', 778, 801, '+', 1, 100, 1, 1, 0, 1, 1), (7, 'P_470786_x2', 782, 805, '+', 1, 100, 1, 2, 0, 1, 1), (8, 'P_246131_x1', 1132, 1155, '+', 1, 100, 1, 1, 0, 1, 1), (9, 'P_472159_x1', 3882, 3905, '+', 1, 100, 1, 1, 0, 1, 1), (10, 'P_252003_x1', 8670, 8689, '+', 1, 100, 1, 1, 0, 1, 1);
