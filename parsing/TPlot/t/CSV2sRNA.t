use Test::More 'no_plan';

use FindBin qw/$Bin/;
use SRNA::Utils qw/ promptUser /;

my $package = 'TPlot::CSV2sRNA';
my $fasta   = '/home/billiau/git/smallRNA/data/tair9genome.fas'; # you will prolly want to change this ;)
use_ok($package) or exit;
can_ok($package, 'run');
can_ok($package, 'run_parser');
can_ok($package, 'new');

# init the tmp db
my $db   = &promptUser('DB', 'kebil_exp_test');
my $user = &promptUser('User for DB', 'kebil');
my $pass = &promptUser('Password for DB', 'kebil');
`echo 'CREATE DATABASE $db' | mysql -u $user -p$pass`;
`mysql -u $user -p$pass $db < $Bin/../../../db/schema.ddl`;

my $csv2srna = new $package({ chr_fasta => $fasta, user => $user, pass => $pass, db => $db });
isa_ok($csv2srna, $package);

my @lines = <DATA>; # read from the bottom of this file, from __DATA__ on
my @sql = @csv = ();
$cur = \@sql;
foreach my $line (@lines) {
    if ($line eq "--\n") {
        $cur = \@csv;
        next;
    }
    push @$cur, $line;
}

{
    ## add a record to the annotations so we can look up the chrom_id
    use DBI;
    my $dbh = DBI->connect("dbi:mysql:database=$db", $user, $pass);
    foreach my $st (@sql) {
        next if $st =~ /^$/;
        $dbh->do($st);
    }
}


my $parsed = $csv2srna->run_parser(\@csv, 1, 1); # lines, exp_id, species_id
my $VAR1 = {
          '892' => [
                     {
                       'id' => 'D-N 0.51',
                       'stop' => 900,
                       'seq' => 'CCTTACTTG',
                       'start' => 892,
                       'score' => 0.51,
                     }
                   ],
          '571' => [
                     {
                       'id' => 'D-N 0.76',
                       'stop' => 589,
                       'seq' => 'TATGTCATCTGCAGACTTG',
                       'start' => 571,
                       'score' => 0.76,
                     }
                   ],
          '1047' => [
                      {
                        'id' => 'D-N 0.51',
                        'stop' => 1065,
                        'seq' => 'TAGCAGTGATACTGAAACT',
                        'start' => 1047,
                        'score' => 0.51,
                      }
                    ],
          '882' => [
                     {
                       'id' => 'D-N 0.68',
                       'stop' => 900,
                       'seq' => 'ACAGCAAGTTCCTTACTTG',
                       'start' => 882,
                       'score' => 0.68
                     }
                   ],
          '1469' => [
                      {
                        'id' => 'D-N 0.51',
                        'stop' => 1487,
                        'seq' => 'TTTTTTTTTGTTTTTTTTT',
                        'start' => 1469,
                        'score' => 0.51
                      }
                    ],
          '590' => [
                     {
                       'id' => 'D-N 0.85',
                       'stop' => 600,
                       'seq' => 'AGTACAAGGGT',
                       'start' => 590,
                       'score' => 0.85
                     },
                   ],
          '589' => [
                     {
                       'id' => 'D-N 0.51',
                       'stop' => 600,
                       'seq' => 'GAGTACAAGGGT',
                       'start' => 589,
                       'score' => 0.51
                     }
                   ],
          '299' => [
                     {
                       'id' => 'D-N 0.5',
                       'stop' => 300,
                       'seq' => 'AA',
                       'start' => 299,
                       'score' => 0.5
                     }
                   ],
          '601' => [
                    undef, undef,
                     {
                       'id' => 'D-N 0.51',
                       'stop' => 619,
                       'seq' => 'GATGATGCGGACATTCTAT',
                       'start' => 601,
                       'score' => 0.51
                     }
                   ],
          '664' => [
                     {
                       'id' => 'D-N 0.51',
                       'stop' => 682,
                       'seq' => 'ACTAGTAGTGCAGGTTCTG',
                       'start' => 664,
                       'score' => 0.51
                     }
                   ],
          '901' => [
                    undef
                   ],
          '480' => [
                     {
                       'id' => 'D-N 0.5',
                       'stop' => 498,
                       'seq' => 'GTTCCTCGATGGAAGATAC',
                       'start' => 480,
                       'score' => 0.5
                     }
                   ],
          '610' => [
                     {
                       'id' => 'D-N 0.51',
                       'stop' => 628,
                       'seq' => 'GACATTCTATCTGCTTATG',
                       'start' => 610,
                       'score' => 0.51
                     }
                   ],
          '301' => [
                    undef
                   ],
          '1198' => [
                      {
                        'id' => 'D-N 0.68',
                        'stop' => 1200,
                        'seq' => 'GAG',
                        'start' => 1198,
                        'score' => 0.68
                      }
                    ],
          '649' => [
                     {
                       'id' => 'D-N 0.59',
                       'stop' => 667,
                       'seq' => 'TTTGTCCCCAATATGACTA',
                       'start' => 649,
                       'score' => 0.59
                     }
                   ],
          '1201' => [
                    undef
                    ],
          '658' => [
                     {
                       'id' => 'D-N 2.03',
                       'stop' => 676,
                       'seq' => 'AATATGACTAGTAGTGCAG',
                       'start' => 658,
                       'score' => 2.03
                     }
                   ]
        };

is_deeply($csv2srna->{ inter_parsed }, $VAR1);

my $result = [
          {
            'chrom_id' => '3',
            'stop' => 317,
            'seq_id' => '1',
            'exp_id' => 1,
            'id' => 'D-N_1_x0.5',
            'score' => 0.5,
            'seq' => 'AATCGAGAGATGCTATGTG',
            'mm_seq' => 'AATCGAGAGATGCTATGTG',
            'mm_num' => 0,
            'start' => 299,
            'genome_start' => 3930,
            'genome_stop' => 3948
          },
          {
            'chrom_id' => '3',
            'stop' => 498,
            'seq_id' => '2',
            'exp_id' => 1,
            'id' => 'D-N_2_x0.5',
            'score' => 0.5,
            'seq' => 'GTTCCTCGATGGAAGATAC',
            'mm_seq' => 'GTTCCTCGATGGAAGATAC',
            'mm_num' => 0,
            'start' => 480,
            'genome_start' => 4111,
            'genome_stop' => 4129
          },
          {
            'chrom_id' => '3',
            'stop' => 589,
            'seq_id' => '3',
            'exp_id' => 1,
            'id' => 'D-N_1_x0.76',
            'score' => 0.76,
            'seq' => 'TATGTCATCTGCAGACTTG',
            'mm_seq' => 'TATGTCATCTGCAGACTTG',
            'mm_num' => 0,
            'start' => 571,
            'genome_start' => 4202,
            'genome_stop' => 4220,
          },
          {
            'chrom_id' => '3',
            'stop' => 607,
            'seq_id' => '4',
            'exp_id' => 1,
            'id' => 'D-N_1_x0.51',
            'score' => 0.51,
            'seq' => 'GAGTACAAGGGTGATGATG',
            'mm_seq' => 'GAGTACAAGGGTGATGATG',
            'mm_num' => 0,
            'start' => 589,
            'genome_start' => 4220,
            'genome_stop' => 4238,
          },
          {
            'chrom_id' => '3',
            'stop' => 608,
            'seq_id' => '5',
            'exp_id' => 1,
            'id' => 'D-N_1_x0.85',
            'score' => 0.85,
            'seq' => 'AGTACAAGGGTGATGATGC',
            'mm_seq' => 'AGTACAAGGGTGATGATGC',
            'mm_num' => 0,
            'start' => 590,
            'genome_start' => 4221,
            'genome_stop' => 4239
          },
          {
            'chrom_id' => '3',
            'stop' => 619,
            'seq_id' => '6',
            'exp_id' => 1,
            'id' => 'D-N_2_x0.51',
            'score' => 0.51,
            'seq' => 'GATGATGCGGACATTCTAT',
            'mm_seq' => 'GATGATGCGGACATTCTAT',
            'mm_num' => 0,
            'start' => 601,
            'genome_start' => 4232,
            'genome_stop' => 4250
          },
          {
            'chrom_id' => '3',
            'stop' => 628,
            'seq_id' => '7',
            'exp_id' => 1,
            'id' => 'D-N_3_x0.51',
            'score' => 0.51,
            'seq' => 'GACATTCTATCTGCTTATG',
            'mm_seq' => 'GACATTCTATCTGCTTATG',
            'mm_num' => 0,
            'start' => 610,
            'genome_start' => 4241,
            'genome_stop' => 4259
          },
          {
            'chrom_id' => '3',
            'stop' => 667,
            'seq_id' => '8',
            'exp_id' => 1,
            'id' => 'D-N_1_x0.59',
            'score' => 0.59,
            'seq' => 'TTTGTCCCCAATATGACTA',
            'mm_seq' => 'TTTGTCCCCAATATGACTA',
            'mm_num' => 0,
            'start' => 649,
            'genome_start' => 4280,
            'genome_stop' => 4298
          },
          {
            'chrom_id' => '3',
            'stop' => 676,
            'seq_id' => '9',
            'exp_id' => 1,
            'id' => 'D-N_1_x2.03',
            'score' => 2.03,
            'seq' => 'AATATGACTAGTAGTGCAG',
            'mm_seq' => 'AATATGACTAGTAGTGCAG',
            'mm_num' => 0,
            'start' => 658,
            'genome_start' => 4289,
            'genome_stop' => 4307 
          },
          {
            'chrom_id' => '3',
            'stop' => 682,
            'seq_id' => '10',
            'exp_id' => 1,
            'id' => 'D-N_4_x0.51',
            'score' => 0.51,
            'seq' => 'ACTAGTAGTGCAGGTTCTG',
            'mm_seq' => 'ACTAGTAGTGCAGGTTCTG',
            'mm_num' => 0,
            'start' => 664,
            'genome_start' => 4295,
            'genome_stop' => 4313
          },
          {
            'chrom_id' => '3',
            'stop' => 900,
            'seq_id' => '11',
            'exp_id' => 1,
            'id' => 'D-N_1_x0.68',
            'score' => 0.68,
            'seq' => 'ACAGCAAGTTCCTTACTTG',
            'mm_seq' => 'ACAGCAAGTTCCTTACTTG',
            'mm_num' => 0,
            'start' => 882,
            'genome_start' => 4513,
            'genome_stop' => 4531
          },
          {
            'chrom_id' => '3',
            'stop' => 910,
            'seq_id' => '12',
            'exp_id' => 1,
            'id' => 'D-N_5_x0.51',
            'score' => 0.51,
            'seq' => 'CCTTACTTGGCACCTTATG',
            'mm_seq' => 'CCTTACTTGGCACCTTATG',
            'mm_num' => 0,
            'start' => 892,
            'genome_start' => 4523,
            'genome_stop' => 4541
          },
          {
            'chrom_id' => '3',
            'stop' => 1065,
            'seq_id' => '13',
            'exp_id' => 1,
            'id' => 'D-N_6_x0.51',
            'score' => 0.51,
            'seq' => 'TAGCAGTGATACTGAAACT',
            'mm_seq' => 'TAGCAGTGATACTGAAACT',
            'mm_num' => 0,
            'start' => 1047,
            'genome_start' => 4678,
            'genome_stop' => 4696 
          },
          {
            'chrom_id' => '3',
            'stop' => 1216,
            'seq_id' => '14',
            'exp_id' => 1,
            'id' => 'D-N_2_x0.68',
            'score' => 0.68,
            'seq' => 'GAGCAACCAAAGCAGCAGA',
            'mm_seq' => 'GAGCAACCAAAGCAGCAGA',
            'mm_num' => 0,
            'start' => 1198,
            'genome_start' => 4829,
            'genome_stop' => 4847
          },
          {
            'chrom_id' => '3',
            'stop' => 1487,
            'seq_id' => '15',
            'exp_id' => 1,
            'id' => 'D-N_7_x0.51',
            'score' => 0.51,
            'seq' => 'TTTTTTTTTGTTTTTTTTT',
            'mm_seq' => 'TTTTTTTTTGTTTTTTTTT',
            'mm_num' => 0,
            'start' => 1469,
            'genome_start' => 5100,
            'genome_stop' => 5118
          }
        ];

is_deeply($parsed, $result);

`echo 'DROP DATABASE $db' | mysql -u $user -p$pass $db`;

__DATA__

INSERT INTO `sources` (`id`, `name`, `description`) VALUES (1, 'TAIR9', '');
INSERT INTO `species` (`id`, `full_name`, `short_name`, `NCBI_tax_id`) VALUES (1, 'Arabidopsis thaliana', 'arath', 3702);
INSERT INTO `chromosomes` (`id`, `name`, `length`, `species_id`) VALUES (3, 'Chr1', 30427671, 1);
INSERT INTO `annotations` (`id`, `accession_nr`, `model_nr`, `start`, `stop`, `strand`, `chromosome_id`, `type`, `species_id`, `seq`, `comment`, `source_id`) VALUES (13032, 'AT1G01010', 1, 3631, 5899, '+', 3, 'mRNA', 1, 'AATTATTAGATATACCAAACCAGAGAAAACAAATACATAATCGGAGAAATACAGATTACAGAGAGCGAGAGAGATCGACGGCGAAGCTCTTTACCCGGAAACCATTGAAATCGGACGGTTTAGTGAAAATGGAGGATCAAGTTGGGTTTGGGTTCCGTCCGAACGACGAGGAGCTCGTTGGTCACTATCTCCGTAACAAAATCGAAGGAAACACTAGCCGCGACGTTGAAGTAGCCATCAGCGAGGTCAACATCTGTAGCTACGATCCTTGGAACTTGCGCTGTAAGTTCCGAATTTTCTGAATTTCATTTGCAAGTAATCGATTTAGGTTTTTGATTTTAGGGTTTTTTTTTGTTTTGAACAGTCCAGTCAAAGTACAAATCGAGAGATGCTATGTGGTACTTCTTCTCTCGTAGAGAAAACAACAAAGGGAATCGACAGAGCAGGACAACGGTTTCTGGTAAATGGAAGCTTACCGGAGAATCTGTTGAGGTCAAGGACCAGTGGGGATTTTGTAGTGAGGGCTTTCGTGGTAAGATTGGTCATAAAAGGGTTTTGGTGTTCCTCGATGGAAGATACCCTGACAAAACCAAATCTGATTGGGTTATCCACGAGTTCCACTACGACCTCTTACCAGAACATCAGGTTTTCTTCTATTCATATATATATATATATATATATGTGGATATATATATATGTGGTTTCTGCTGATTCATAGTTAGAATTTGAGTTATGCAAATTAGAAACTATGTAATGTAACTCTATTTAGGTTCAGCAGCTATTTTAGGCTTAGCTTACTCTCACCAATGTTTTATACTGATGAACTTATGTGCTTACCTCCGGAAATTTTACAGAGGACATATGTCATCTGCAGACTTGAGTACAAGGGTGATGATGCGGACATTCTATCTGCTTATGCAATAGATCCCACTCCCGCTTTTGTCCCCAATATGACTAGTAGTGCAGGTTCTGTGGTGAGTCTTTCTCCATATACACTTAGCTTTGAGTAGGCAGATCAAAAAAGAGCTTGTGTCTACTGATTTGATGTTTTCCTAAACTGTTGATTCGTTTCAGGTCAACCAATCACGTCAACGAAATTCAGGATCTTACAACACTTACTCTGAGTATGATTCAGCAAATCATGGCCAGCAGTTTAATGAAAACTCTAACATTATGCAGCAGCAACCACTTCAAGGATCATTCAACCCTCTCCTTGAGTATGATTTTGCAAATCACGGCGGTCAGTGGCTGAGTGACTATATCGACCTGCAACAGCAAGTTCCTTACTTGGCACCTTATGAAAATGAGTCGGAGATGATTTGGAAGCATGTGATTGAAGAAAATTTTGAGTTTTTGGTAGATGAAAGGACATCTATGCAACAGCATTACAGTGATCACCGGCCCAAAAAACCTGTGTCTGGGGTTTTGCCTGATGATAGCAGTGATACTGAAACTGGATCAATGGTAAGCTTTTTTTACTCATATATAATCACAACCTATATCGCTTCTATATCTCACACGCTGAATTTTGGCTTTTAACAGATTTTCGAAGACACTTCGAGCTCCACTGATAGTGTTGGTAGTTCAGATGAACCGGGCCATACTCGTATAGATGATATTCCATCATTGAACATTATTGAGCCTTTGCACAATTATAAGGCACAAGAGCAACCAAAGCAGCAGAGCAAAGAAAAGGTTTAACACTCTCACTGAGAAACATGACTTTGATACGAAATCTGAATCAACATTTCATCAAAAAGATTTAGTCAAATGACCTCTAAATTATGAGCTATGGGTCTGCTTTCAGGTGATAAGTTCGCAGAAAAGCGAATGCGAGTGGAAAATGGCTGAAGACTCGATCAAGATACCTCCATCCACCAACACGGTGAAGCAGAGCTGGATTGTTTTGGAGAATGCACAGTGGAACTATCTCAAGAACATGATCATTGGTGTCTTGTTGTTCATCTCCGTCATTAGTTGGATCATTCTTGTTGGTTAAGAGGTCAAATCGGATTCTTGCTCAAAATTTGTATTTCTTAGAATGTGTGTTTTTTTTTGTTTTTTTTTCTTTGCTCTGTTTTCTCGCTCCGGAAAAGTTTGAAGTTATATTTTATTAGTATGTAAAGAAGAGAAAAAGGGGGAAAGAAGAGAGAAGAAAAATGCAGAAAATCATATATATGAATTGGAAAAAAGTATATGTAATAATAATTAGTGCATCGTTTTGTGGTGTAGTTTATATAAATAAAGTGATATATAGTCTTGTATAAG', '', 1);
--
1                                                                                                100
AAATTATTAGATATACCAAACCAGAGAAAACAAATACATAATCGGAGAAATACAGATTACAGAGAGCGAGAGAGATCGACGGCGAAGCTCTTTACCCGGA	AT1G01010.1


101                                                                                              200
AACCATTGAAATCGGACGGTTTAGTGAAAATGGAGGATCAAGTTGGGTTTGGGTTCCGTCCGAACGACGAGGAGCTCGTTGGTCACTATCTCCGTAACAA	AT1G01010.1


201                                                                                              300
AATCGAAGGAAACACTAGCCGCGACGTTGAAGTAGCCATCAGCGAGGTCAACATCTGTAGCTACGATCCTTGGAACTTGCGCTTCCAGTCAAAGTACAAA	AT1G01010.1
                                                                                                  AA	D-N 0.5


301                                                                                              400
TCGAGAGATGCTATGTGGTACTTCTTCTCTCGTAGAGAAAACAACAAAGGGAATCGACAGAGCAGGACAACGGTTTCTGGTAAATGGAAGCTTACCGGAG	AT1G01010.1
TCGAGAGATGCTATGTG                                                                                   	D-N 0.5


401                                                                                              500
AATCTGTTGAGGTCAAGGACCAGTGGGGATTTTGTAGTGAGGGCTTTCGTGGTAAGATTGGTCATAAAAGGGTTTTGGTGTTCCTCGATGGAAGATACCC	AT1G01010.1
                                                                               GTTCCTCGATGGAAGATAC  	D-N 0.5


501                                                                                              600
TGACAAAACCAAATCTGATTGGGTTATCCACGAGTTCCACTACGACCTCTTACCAGAACATCAGAGGACATATGTCATCTGCAGACTTGAGTACAAGGGT	AT1G01010.1
                                                                                         AGTACAAGGGT	D-N 0.85
                                                                      TATGTCATCTGCAGACTTG           	D-N 0.76
                                                                                        GAGTACAAGGGT	D-N 0.51


601                                                                                              700
GATGATGCGGACATTCTATCTGCTTATGCAATAGATCCCACTCCCGCTTTTGTCCCCAATATGACTAGTAGTGCAGGTTCTGTGGTCAACCAATCACGTC	AT1G01010.1
                                                         AATATGACTAGTAGTGCAG                        	D-N 2.03
GATGATGC                                                                                            	D-N 0.85
                                                TTTGTCCCCAATATGACTA                                 	D-N 0.59
GATGATG                                                                                             	D-N 0.51
GATGATGCGGACATTCTAT                                                                                 	D-N 0.51
                                                               ACTAGTAGTGCAGGTTCTG                  	D-N 0.51
         GACATTCTATCTGCTTATG                                                                        	D-N 0.51


701                                                                                              800
AACGAAATTCAGGATCTTACAACACTTACTCTGAGTATGATTCAGCAAATCATGGCCAGCAGTTTAATGAAAACTCTAACATTATGCAGCAGCAACCACT	AT1G01010.1


801                                                                                              900
TCAAGGATCATTCAACCCTCTCCTTGAGTATGATTTTGCAAATCACGGCGGTCAGTGGCTGAGTGACTATATCGACCTGCAACAGCAAGTTCCTTACTTG	AT1G01010.1
                                                                                 ACAGCAAGTTCCTTACTTG	D-N 0.68
                                                                                           CCTTACTTG	D-N 0.51


901                                                                                             1000
GCACCTTATGAAAATGAGTCGGAGATGATTTGGAAGCATGTGATTGAAGAAAATTTTGAGTTTTTGGTAGATGAAAGGACATCTATGCAACAGCATTACA	AT1G01010.1
GCACCTTATG                                                                                          	D-N 0.51


1001                                                                                            1100
GTGATCACCGGCCCAAAAAACCTGTGTCTGGGGTTTTGCCTGATGATAGCAGTGATACTGAAACTGGATCAATGATTTTCGAAGACACTTCGAGCTCCAC	AT1G01010.1
                                              TAGCAGTGATACTGAAACT                                   	D-N 0.51


1101                                                                                            1200
TGATAGTGTTGGTAGTTCAGATGAACCGGGCCATACTCGTATAGATGATATTCCATCATTGAACATTATTGAGCCTTTGCACAATTATAAGGCACAAGAG	AT1G01010.1
                                                                                                 GAG	D-N 0.68


1201                                                                                            1300
CAACCAAAGCAGCAGAGCAAAGAAAAGGTGATAAGTTCGCAGAAAAGCGAATGCGAGTGGAAAATGGCTGAAGACTCGATCAAGATACCTCCATCCACCA	AT1G01010.1
CAACCAAAGCAGCAGA                                                                                    	D-N 0.68


1301                                                                                            1400
ACACGGTGAAGCAGAGCTGGATTGTTTTGGAGAATGCACAGTGGAACTATCTCAAGAACATGATCATTGGTGTCTTGTTGTTCATCTCCGTCATTAGTTG	AT1G01010.1


1401                                                                                            1500
GATCATTCTTGTTGGTTAAGAGGTCAAATCGGATTCTTGCTCAAAATTTGTATTTCTTAGAATGTGTGTTTTTTTTTGTTTTTTTTTCTTTGCTCTGTTT	AT1G01010.1
                                                                    TTTTTTTTTGTTTTTTTTT             	D-N 0.51


1501                                                                                            1600
TCTCGCTCCGGAAAAGTTTGAAGTTATATTTTATTAGTATGTAAAGAAGAGAAAAAGGGGGAAAGAAGAGAGAAGAAAAATGCAGAAAATCATATATATG	AT1G01010.1


1601                                                                                            1700
AATTGGAAAAAAGTATATGTAATAATAATTAGTGCATCGTTTTGTGGTGTAGTTTATATAAATAAAGTGATATATAGTCTTGTATAAG            	AT1G01010.1


