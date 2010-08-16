#!/usr/bin/perl

use strict;
use warnings;
use DBI;
use Smart::Comments;
use Data::Dumper;
use Settings qw/:DB/;

my $path = $ARGV[0] || die "Gimme a export dir\n";

my $dbi = DBI->connect('dbi:mysql:database='.DB, USER, PASS);

my $annoth = $dbi->prepare(q{ SELECT id FROM annotations WHERE start <= ? AND stop >= ? AND chromosome_id = ? });

my @results = ();
my $writebuffer = 1_000_000; # after how many results do we write out to disk
my $i = 0; # result counter
my $j = 0; # file counter
my $limit = 10000; # how many records do we extract per round
my $start = 1; # start at the first row, of course

my $num_results = 1;
while ($num_results) {
    my $sth = $dbi->prepare(qq{ SELECT annotations.id, srnas.id FROM srnas JOIN annotations ON (annotations.chromosome_id = srnas.chromosome_id AND annotations.start <= srnas.start AND annotations.stop >= srnas.stop) LIMIT $start, $limit });
    $sth->execute();
    $num_results = 0;
    while (my @row = $sth->fetchrow_array()) { ### [%]
        $num_results++;
        
        push @results, [ @row ];
        $i++;
        if ($i == $writebuffer) {
            &fprint($path, ++$j); # export to file

            @results = ();
            $i = 0;
        }
    }
    $start += $limit;
}
if (@results) {
    &fprint($path, ++$j); # export to file
}
### tried $j times ...

sub fprint {
    my $file = shift;
    my $content = shift;

    if (open(FF, '>', $file)) {
        print FF $content;
        close FF;
    }
    else {
        warn "Failed to write to $file!";
    }
}
1;

__END__
