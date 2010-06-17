#!/usr/bin/perl
package SRNA::Trunc;

use strict;
use warnings;
use DBI;
use Getopt::Long;
use Pod::Usage;

&run() if ! caller();

sub run {
    my ($user, $pass, $db) = q{};
    my $host = 'localhost';
    my @tables = ();
    my $opts = GetOptions(
        'user=s' => \$user,
        'pass=s' => \$pass,
        'db=s'   => \$db,
        'host:s' => \$host,
        'table:s' => \@tables,
    );

    pod2usage(2) if (!$user || !$pass || !$db || !$host);

    print "$pass\n";
    my $dbh = DBI->connect("dbi:mysql:database=$db;host=$host", $user, $pass);

    if (! scalar @tables) {
        @tables = @{ $dbh->selectcol_arrayref("SHOW tables FROM $db") };
    }

    print "Are you sure you want to truncate following tables:\n";
    print ' * ';
    print join "\n * ", @tables;
    print "\n";
    print 'Y/N: ';
    my $ans = <STDIN>;
    chomp $ans;
    $ans = uc($ans);
    exit if $ans ne 'Y';

    $dbh->do('SET FOREIGN_KEY_CHECKS = 0');
    foreach my $table (@tables) {
        print "TRUNCATE $table;\n";
        $dbh->do("TRUNCATE $table");
    }
    $dbh->do('SET FOREIGN_KEY_CHECKS = 1');

    print "Done!";
}

__END__

=head1 SYNOPSIS

Usage: perl SRNA/Trunc.pm --user <db username> --pass <db password> --db <db name>

Optional:
  --host <db hostname>, defaults to localhost
  --table <tablename>, table to truncate. You can give multiple of these options.

