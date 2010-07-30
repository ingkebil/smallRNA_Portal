use Test::More 'no_plan';

use Data::Dumper;
use FindBin qw/$Bin/;

use SRNA::Utils qw/ promptUser /;
use FASTA::Reader;
my $package = 'GFF::Exp2sRNA';
my $chrfasta = '/home/billiau/git/smallRNA/data/tair9genome.fas';
use_ok($package) or exit;
can_ok($package, 'run');
can_ok($package, 'new');
can_ok($package, 'run_parser');
can_ok($package, 'fprint');
can_ok($package, 'make_output');
can_ok($package, 'csv_adder');
can_ok($package, 'add_seq');
can_ok($package, 'add_type');
can_ok($package, 'get_next_id');
can_ok($package, 'get_cur_id');


# get some sample data
my @lines = <DATA>; # read from the bottom of this file
my @gff = @fasta = ();
$cur = \@gff;
foreach my $line (@lines) {
    if ($line eq "--\n") {
        $cur = \@fasta;
        next;
    }
    push @$cur, $line;
}

# init the tmp db
my $db   = &promptUser('DB', 'kebil_exp_test');
my $user = &promptUser('User for DB', 'kebil');
my $pass = &promptUser('Password for DB', 'kebil');
`echo 'CREATE DATABASE $db' | mysql -u $user -p$pass`;
`mysql -u $user -p$pass $db < $Bin/../../../db/schema.ddl`;

# create our test object
my $exp = new $package({ chr_fasta => $chrfasta, user => $user, pass => $pass, db => $db });
isa_ok($exp, $package);

# add the sequences to our parser
$exp->{ freader }->add_regex('exp_fasta' => '>(.*)');
$exp->{ freader }->{ lines } = \@fasta;
$exp->{ freader }->_fasta('exp_fasta');
$exp->{ fasta_file } = 'exp_fasta';
$exp->{ fasta_id_regex } = '>(.*)';

# run the parser
$exp->run_parser(\@gff, 1, 'smallrna', 1);

is_deeply(
    $exp->{ return }->{ csv },
    {
        'types' => [
            '\'1\'	\'smallrna\''
        ],
        'srnas'	=>	[
            '1	\'P_701714_x1\'	\'754\'	\'776\'	\'+\'	\'1\'	\'100\'	\'1\'	\'1\'	NULL	\'1\'	\'1\'',
            '2	\'P_498551_x1\'	\'755\'	\'778\'	\'+\'	\'2\'	\'100\'	\'1\'	\'1\'	NULL	\'1\'	\'1\'',
            '3	\'P_237009_x5\'	\'762\'	\'785\'	\'+\'	\'3\'	\'100\'	\'1\'	\'5\'	NULL	\'1\'	\'1\'',
            '4	\'P_409085_x2\'	\'771\'	\'794\'	\'+\'	\'4\'	\'100\'	\'1\'	\'2\'	NULL	\'1\'	\'1\'',
            '5	\'P_107660_x21\'	\'774\'	\'797\'	\'+\'	\'5\'	\'100\'	\'1\'	\'21\'	NULL	\'1\'	\'1\'',
            '6	\'P_97981_x1\'	\'778\'	\'801\'	\'+\'	\'6\'	\'100\'	\'1\'	\'1\'	NULL	\'1\'	\'1\'',
            '7	\'P_470786_x2\'	\'782\'	\'805\'	\'+\'	\'7\'	\'100\'	\'1\'	\'2\'	NULL	\'1\'	\'1\'',
            '8	\'P_246131_x1\'	\'1132\'	\'1155\'	\'+\'	\'8\'	\'100\'	\'1\'	\'1\'	NULL	\'1\'	\'1\'',
            '9	\'P_472159_x1\'	\'3882\'	\'3905\'	\'+\'	\'9\'	\'100\'	\'1\'	\'1\'	NULL	\'1\'	\'1\'',
            '10	\'P_252003_x1\'	\'8670\'	\'8689\'	\'+\'	\'10\'	\'100\'	\'1\'	\'1\'	NULL	\'1\'	\'1\''
        ],
        'chromosomes'	=>	[
            '1	Chr1	30427671	1'
        ],
        'sequences'	=>	[
            '\'1\'	\'CTTTATTTAGAGTGATTTGGATG\'',
            '\'2\'	\'TTTTTTTAGAGTGATTTGGATGAT\'',
            '\'3\'	\'AGAGTGATTTGGATGATTCAAGAC\'',
            '\'4\'	\'TGGATGATTCAAGACTTCTCGGTA\'',
            '\'5\'	\'ATGATTCAAGACTTCTCGGTACTG\'',
            '\'6\'	\'TTCAAGACTTCTCGGTACTGCAAA\'',
            '\'7\'	\'AGACTTCTCGGTACTGCAAAGTTC\'',
            '\'8\'	\'ATAAATAAGTTTATGGTTAAGAGT\'',
            '\'9\'	\'CATCTGTAGCTACGATCCTTGGAA\'',
            '\'10\'	\'TCTCTCTCTCTCTCTCTCTC\''
        ],
        'mismatches' => [
            'NULL	\'1\'	\'758\'',
        ]
    },
);

# drop the db
`echo 'DROP DATABASE $db' | mysql -u $user -p$pass`;

__DATA__

Chr1	AGScheible	smallRNA	754	776	100	+	.	P_701714_x1
Chr1	AGScheible	smallRNA	755	778	100	+	.	P_498551_x1
Chr1	AGScheible	smallRNA	762	785	100	+	.	P_237009_x5
Chr1	AGScheible	smallRNA	771	794	100	+	.	P_409085_x2
Chr1	AGScheible	smallRNA	774	797	100	+	.	P_107660_x21
Chr1	AGScheible	smallRNA	778	801	100	+	.	P_97981_x1
Chr1	AGScheible	smallRNA	782	805	100	+	.	P_470786_x2
Chr1	AGScheible	smallRNA	1132	1155	100	+	.	P_246131_x1
Chr1	AGScheible	smallRNA	3882	3905	100	+	.	P_472159_x1
Chr1	AGScheible	smallRNA	8670	8689	100	+	.	P_252003_x1
--
>P_701714_x1
CTTTATTTAGAGTGATTTGGATG
>P_498551_x1
TTTTTTTAGAGTGATTTGGATGAT
>P_237009_x5
AGAGTGATTTGGATGATTCAAGAC
>P_409085_x2
TGGATGATTCAAGACTTCTCGGTA
>P_107660_x21
ATGATTCAAGACTTCTCGGTACTG
>P_97981_x1
TTCAAGACTTCTCGGTACTGCAAA
>P_470786_x2
AGACTTCTCGGTACTGCAAAGTTC
>P_246131_x1
ATAAATAAGTTTATGGTTAAGAGT
>P_472159_x1
CATCTGTAGCTACGATCCTTGGAA
>P_252003_x1
TCTCTCTCTCTCTCTCTCTC
