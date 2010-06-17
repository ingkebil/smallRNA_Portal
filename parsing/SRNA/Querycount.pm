package SRNA::Querycount;

use strict;
use warnings;
use DBI;
use FASTA::Reader;
use String::CRC32;
use Time::HiRes qw/ gettimeofday tv_interval /;

my $dbi = DBI->connect('dbi:mysql:database=smallrna', 'kebil', 'kebil');
my $f  ='/home/billiau/git/smallRNA/data/P.unique.sample.fas';
my $b ='/home/billiau/git/smallRNA/data/P.unique.fas';
my $r = FASTA::Reader->new({ filename => $f });
$r->add_regex($b);

my @seqs = values %{ $r->get_all_seq($f) };
my @more_seqs = values %{ $r->get_all_seq($b) };

my $s1 = \@seqs;
my $s2 = \@more_seqs;

#$dbi->do(q{IF EXISTS `seq` ALTER TABLE `sequences` DROP INDEX `seq` });

print "No Index\n";
&exe($s1, $s1, $s1);

#$dbi->do(q{ALTER TABLE `sequences` DROP INDEX `seq` });
$dbi->do(q{ALTER TABLE `sequences` ADD INDEX `seq` ( `seq_hash` ) });

print "Index hash\n";
&exe($s1, $s1, $s1);

$dbi->do(q{ALTER TABLE `sequences` DROP INDEX `seq` });
$dbi->do(q{ALTER TABLE `sequences` ADD INDEX `seq` ( `seq` ) });

print "Index seq\n";
&exe($s2, $s1, $s2);

$dbi->do(q{ALTER TABLE `sequences` DROP INDEX `seq` });
$dbi->do(q{ALTER TABLE `sequences` ADD INDEX `seq` ( `seq_hash`, `seq` ) });

print "Index both\n";
&exe($s1, $s1, $s1);

$dbi->do(q{ALTER TABLE `sequences` DROP INDEX `seq` });
$dbi->do(q{ALTER TABLE `sequences` ADD UNIQUE `seq` ( `seq` ) });

print "Unique seq\n";
&exe($s2, $s1, $s2);

$dbi->do(q{ALTER TABLE `sequences` DROP INDEX `seq` });

sub exe {
    my ($s1, $s2, $s3) = @_;

    my $start = [gettimeofday()];
    my $sth = $dbi->prepare(q{ SELECT id FROM `sequences` WHERE seq = ? });
    foreach my $seq (@{ $s1 }) {
        $sth->execute( $seq );
    }
    my $stop = [gettimeofday()];

    print "\tSeq alone\n";
    print "\tTotal: " . tv_interval($start, $stop) . "s\n";
    print "\tq/s  : " . scalar(@seqs)/tv_interval($start, $stop) . "q/s\n";

    $start = [gettimeofday()];
    $sth = $dbi->prepare(q{ SELECT id FROM `sequences` WHERE seq_hash = CRC32(?) });
    foreach my $seq (@{ $s2 }) {
        $sth->execute( $seq );
    }
    $stop = [gettimeofday()];

    print "\tMySQL CRC32 alone\n";
    print "\tTotal: " . tv_interval($start, $stop) . "s\n";
    print "\tq/s  : " . scalar(@seqs)/tv_interval($start, $stop) . "q/s\n";

    $start = [gettimeofday()];
    $sth = $dbi->prepare(q{ SELECT id FROM `sequences` WHERE seq_hash = ? });
    foreach my $seq (@{ $s2 }) {
        $sth->execute( crc32($seq) );
    }
    $stop = [gettimeofday()];

    print "\tPerl CRC32 alone\n";
    print "\tTotal: " . tv_interval($start, $stop) . "s\n";
    print "\tq/s  : " . scalar(@seqs)/tv_interval($start, $stop) . "q/s\n";

    $start = [gettimeofday()];
    $sth = $dbi->prepare(q{ SELECT id FROM `sequences` WHERE seq_hash = CRC32(?) AND seq = ? });
    foreach my $seq (@{ $s3 }) {
        $sth->execute( $seq, $seq );
    }
    $stop = [gettimeofday()];

    print "\tMySQL CRC32 AND seq\n";
    print "\tTotal: " . tv_interval($start, $stop) . "s\n";
    print "\tq/s  : " . scalar(@seqs)/tv_interval($start, $stop) . "q/s\n";

    $start = [gettimeofday()];
    $sth = $dbi->prepare(q{ SELECT id FROM `sequences` WHERE seq_hash = ? AND seq = ? });
    foreach my $seq (@{ $s3 }) {
        $sth->execute( crc32($seq), $seq );
    }
    $stop = [gettimeofday()];

    print "\tPerl CRC32 AND seq\n";
    print "\tTotal: " . tv_interval($start, $stop) . "s\n";
    print "\tq/s  : " . scalar(@seqs)/tv_interval($start, $stop) . "q/s\n";

    print "\n";
}

1;
