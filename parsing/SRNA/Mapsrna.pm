#!/usr/bin/perl
package SRNA::Mapsrna;

use strict;
use warnings;
use DBI;
use Smart::Comments;
use Data::Dumper;
use Settings qw/:DB/;

my $path = $ARGV[0] || die "Gimme a export dir\n";

my $dbi = DBI->connect('dbi:mysql:database='.DB, USER, PASS);

my $annoth = $dbi->prepare(q{ SELECT id FROM annotations WHERE chromosome_id = ? AND stop >= ? AND start <= ? });
my $sth = $dbi->prepare(qq{ SELECT srnas.id, chromosome_id, stop, start FROM srnas ORDER BY stop, id });
$sth->execute();
my @results = ();
my $writebuffer = 1_000_000; # after how many results do we write out to disk
my $i = 0; # result counter
my $j = 0; # file counter

while (my @row = $sth->fetchrow_array()) { ### [%]
    my $rs = $dbi->selectall_arrayref($annoth, {}, @row[1..3] );
    
    foreach my $r (@$rs) {
        push @results, "$r->[ 0 ]\t$row[ 0 ]";
        $i++;
        if ($i == $writebuffer) {
            &fprint($path, ++$j, \@results); # export to file
    
            @results = ();
            $i = 0;
        }
    }
}
if (@results) {
    &fprint($path, ++$j, \@results); # export to file
}
### tried $j times ...

sub fprint {
    my $path = shift;
    my $try = shift;
    my $content = shift;
    my $file = "$path/mappings.slow.$try.csv";

    if (open(FF, '>', $file)) {
        print FF join "\n", @$content;
        close FF;
    }
    else {
        warn "Failed to write to $file!";
    }
}
1;

__END__

=head1 SYNOPSIS

This is a slow version of the mapping script. As soon as the DB becomes so
large that indexes don't fit in mem anylonger, then the range query becomes
extremely slow.

Use Smapsrna.pm instead!
