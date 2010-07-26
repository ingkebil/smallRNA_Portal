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

my @lines = <DATA>; # read from the bottom of this file, from __DATA__ on
my $csv2srna = new $package({ chr_fasta => $fasta, user => $user, pass => $pass, db => $db });
isa_ok($csv2srna, $package);

my $parsed = $csv2srna->run_parser(\@lines, 1, 1); # lines, exp_id, species_id
my $VAR1 = {
          '892' => [
                     {
                       'id' => 'D-N 0.51',
                       'stop' => 900,
                       'seq' => 'CCTTACTTG',
                       'start' => 892
                     }
                   ],
          '571' => [
                     {
                       'id' => 'D-N 0.76',
                       'stop' => 589,
                       'seq' => 'TATGTCATCTGCAGACTTG',
                       'start' => 571
                     }
                   ],
          '1047' => [
                      {
                        'id' => 'D-N 0.51',
                        'stop' => 1065,
                        'seq' => 'TAGCAGTGATACTGAAACT',
                        'start' => 1047
                      }
                    ],
          '882' => [
                     {
                       'id' => 'D-N 0.68',
                       'stop' => 900,
                       'seq' => 'ACAGCAAGTTCCTTACTTG',
                       'start' => 882
                     }
                   ],
          '1469' => [
                      {
                        'id' => 'D-N 0.51',
                        'stop' => 1487,
                        'seq' => 'TTTTTTTTTGTTTTTTTTT',
                        'start' => 1469
                      }
                    ],
          '590' => [
                     {
                       'id' => 'D-N 0.85',
                       'stop' => 600,
                       'seq' => 'AGTACAAGGGT',
                       'start' => 590
                     },
                   ],
          '589' => [
                     {
                       'id' => 'D-N 0.51',
                       'stop' => 600,
                       'seq' => 'GAGTACAAGGGT',
                       'start' => 589
                     }
                   ],
          '299' => [
                     {
                       'id' => 'D-N 0.5',
                       'stop' => 300,
                       'seq' => 'AA',
                       'start' => 299
                     }
                   ],
          '601' => [
                    undef, undef,
                     {
                       'id' => 'D-N 0.51',
                       'stop' => 619,
                       'seq' => 'GATGATGCGGACATTCTAT',
                       'start' => 601
                     }
                   ],
          '664' => [
                     {
                       'id' => 'D-N 0.51',
                       'stop' => 682,
                       'seq' => 'ACTAGTAGTGCAGGTTCTG',
                       'start' => 664
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
                       'start' => 480
                     }
                   ],
          '610' => [
                     {
                       'id' => 'D-N 0.51',
                       'stop' => 628,
                       'seq' => 'GACATTCTATCTGCTTATG',
                       'start' => 610
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
                        'start' => 1198
                      }
                    ],
          '649' => [
                     {
                       'id' => 'D-N 0.59',
                       'stop' => 667,
                       'seq' => 'TTTGTCCCCAATATGACTA',
                       'start' => 649
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
                       'start' => 658
                     }
                   ]
        };

is_deeply($csv2srna->{ parsed }, $VAR1);

my $result = [
        {
            'stop' => 317,
            'id' => 'D-N_1_x0.5',
            'seq' => 'AATCGAGAGATGCTATGTG',
            'start' => 299
          },
          {
            'stop' => 498,
            'id' => 'D-N_2_x0.5',
            'seq' => 'GTTCCTCGATGGAAGATAC',
            'start' => 480
          },
          {
            'stop' => 589,
            'id' => 'D-N_1_x0.76',
            'seq' => 'TATGTCATCTGCAGACTTG',
            'start' => 571
          },
          {
            'stop' => 607,
            'id' => 'D-N_1_x0.51',
            'seq' => 'GAGTACAAGGGTGATGATG',
            'start' => 589
          },
          {
            'stop' => 608,
            'id' => 'D-N_1_x0.85',
            'seq' => 'AGTACAAGGGTGATGATGC',
            'start' => 590
          },
          {
            'stop' => 619,
            'id' => 'D-N_2_x0.51',
            'seq' => 'GATGATGCGGACATTCTAT',
            'start' => 601
          },
          {
            'stop' => 628,
            'id' => 'D-N_3_x0.51',
            'seq' => 'GACATTCTATCTGCTTATG',
            'start' => 610
          },
          {
            'stop' => 667,
            'id' => 'D-N_1_x0.59',
            'seq' => 'TTTGTCCCCAATATGACTA',
            'start' => 649
          },
          {
            'stop' => 676,
            'id' => 'D-N_1_x2.03',
            'seq' => 'AATATGACTAGTAGTGCAG',
            'start' => 658
          },
          {
            'stop' => 682,
            'id' => 'D-N_4_x0.51',
            'seq' => 'ACTAGTAGTGCAGGTTCTG',
            'start' => 664
          },
          {
            'stop' => 900,
            'id' => 'D-N_1_x0.68',
            'seq' => 'ACAGCAAGTTCCTTACTTG',
            'start' => 882
          },
          {
            'stop' => 910,
            'id' => 'D-N_5_x0.51',
            'seq' => 'CCTTACTTGGCACCTTATG',
            'start' => 892
          },
          {
            'stop' => 1065,
            'id' => 'D-N_6_x0.51',
            'seq' => 'TAGCAGTGATACTGAAACT',
            'start' => 1047
          }, 
          {
            'stop' => 1216,
            'id' => 'D-N_2_x0.68',
            'seq' => 'GAGCAACCAAAGCAGCAGA',
            'start' => 1198
          },
          {
            'stop' => 1487,
            'id' => 'D-N_7_x0.51',
            'seq' => 'TTTTTTTTTGTTTTTTTTT',
            'start' => 1469
          }
        ];

is_deeply($parsed, $result);

__DATA__

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


