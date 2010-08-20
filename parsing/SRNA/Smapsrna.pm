#!/usr/bin/perl
package SRNA::Smapsrna;

use strict;
use warnings;
use DBI;
use Smart::Comments;
use Settings qw/:DB/;

&run(@ARGV) unless caller();

sub run {
    my $path = shift || die "Gimme a export dir\n";
    my $user = shift || USER;
    my $pass = shift || PASS;
    my $db   = shift || DB;

    my $dbi = DBI->connect('dbi:mysql:database='.$db, $user, $pass);
    my $annoth = $dbi->prepare(q{ SELECT id, start, stop FROM annotations WHERE chromosome_id = ? ORDER BY stop });
    my $srnah = $dbi->prepare(qq{ SELECT srnas.id, start, stop FROM srnas WHERE chromosome_id = ? ORDER BY stop });
    my $chr_ids = $dbi->selectcol_arrayref(q{ SELECT id FROM chromosomes WHERE species_id = 1 });

    my @results = ();
    my $j = 0; # file counter
    foreach my $chr_id (@$chr_ids) {
        my $annots = $dbi->selectall_arrayref($annoth, {}, ( $chr_id ) );
        print '--';
        print scalar @$annots;
        print "--\n";
        $srnah->execute( ( $chr_id ) );

        @results = ();
        my $writebuffer = 500_000; # after how many results do we write out to disk
        my $i = 0; # result counter
        my $begin_index = 0;
        my $c = 0;

        while (my @row = $srnah->fetchrow_array()) { ## [%]
        
            $begin_index = &find_first($annots, $row[1], $row[2], $begin_index);
            my $indexes  = &find_indexes($annots, $row[1], $row[2], $begin_index);

            for my $r (@$indexes) {
                push @results, "$annots->[ $r ]->[0]\t$row[0]";
                $i++;
                if ($i == $writebuffer) {
                    &fprint($path, ++$j . ".$chr_id", \@results); # export to file
            
                    @results = ();
                    $i = 0;
                }
            }
            $c++;
            print "\r[$i] $c"; # some info that the program _is_ running
        }
        if (@results) {
            &fprint($path, ++$j . ".$chr_id", \@results); # export to file
        }
        ### tried $j times ...
    }
    return \@results; # this is only here for the test file
}

=head1

=cut
sub find_first {
    my ($rs, $start, $stop, $begin_index) = @_;
    $begin_index ||=0;

    my $i = 0;
    for($i = $begin_index; $i < scalar @$rs; $i++) {
        next if $rs->[$i]->[2] < $stop;
        last;
    }

    return $begin_index if $i == scalar @$rs; # we just transversed the whole array and are out of bounds
    return $i;
}

sub find_indexes {
    my ($rs, $start, $stop, $begin_index) = @_;

    $begin_index ||= 0;
    my $i = $begin_index;
    my @indexes = ();

    while ($i < scalar @$rs && $rs->[$i]->[2] >= $stop) {
        if ($rs->[$i]->[1] <= $start) {
            push @indexes, $i;
        }
        $i++;
    }
    print ' ', $i - $begin_index , ';';

    return \@indexes;
}

sub fprint {
    my $path = shift;
    my $try = shift;
    my $content = shift;
    my $file = "$path/mappings.$try.csv";

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
