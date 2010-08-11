#/usr/bin/perl
package SRNA::Normabun_all;

use strict;
use warnings;
use DBI;
use Settings qw/:DB/;
use FindBin qw/$Bin/;

my $user = USER;
my $pass = USER;
my $db = DB;

my $dbi = DBI->connect('dbi:mysql:database='.$db, $user, $pass);

my @conds = map { chomp; $_ } `ls $ARGV[0]`;

foreach my $cond (@conds) {
    my $exp_id = $dbi->selectrow_arrayref(q{ SELECT id FROM `experiments` WHERE name = ? }, {}, ( $cond ))->[0];
    print "perl $Bin/../SRNA/Normabun.pm --exp-id $exp_id $ARGV[0]/$cond\n";
    `perl $Bin/../SRNA/Normabun.pm --exp-id $exp_id $ARGV[0]/$cond`;
     print "mysql -u $user -p $db < $file\n";
     `mysql -u $user -p$pass $db < $file`;
}
