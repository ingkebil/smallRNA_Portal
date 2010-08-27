#!/usr/bin/perl
package SRNA::Mappinginstruct;

use strict;
use warnings;
use DBI;
use Data::Dumper;
use Settings qw/:DB/;

&run(@ARGV) unless caller();

sub run {
    my $user = shift || USER;
    my $pass = shift || PASS;
    my $db   = shift || DB;

    my $dbi = DBI->connect('dbi:mysql:database='.$db, $user, $pass);
    my $structh = $dbi->prepare(q{ SELECT id, annotation_id, start, stop, utr FROM structures ORDER BY annotation_id, stop });
    my $srnah = $dbi->prepare(qq{ SELECT s.id, start, stop FROM srnas s JOIN mappings m ON s.id = m.srna_id WHERE m.annotation_id = ? });

    my $structs = $dbi->selectall_arrayref($structh, { Slice => {} });

    print 'Got: ' . scalar @$structs;
    print "\n\n";
    my $annot_id = 0;
    my $srnas;
    my $i = 0; # count srnas
    my $m = 0; # marked
    foreach my $struct (@$structs) {
        if ($struct->{ annotation_id } != $annot_id) {
            if ($annot_id) {
                foreach my $s (@$srnas) {
                    if (! exists $s->{ marked }) {
                        print Dumper $s;
                    }
                }
            }
            $srnas = $dbi->selectall_arrayref($srnah, { Slice => {} }, $struct->{ annotation_id });
            $annot_id = $struct->{ annotation_id };
            $i = 0; # count srnas
            $m = 0; # marked
            print "\n";
        }

        foreach my $srna (@$srnas) {
            if ($srna->{ start } >= $struct->{ start } &&
                $srna->{ stop  } <= $struct->{ stop  }) {
                $srna->{ marked } = 1;
                $m++;
            }
            print "\r                                                                      \r";
            print $struct->{ id }, ' ', $struct->{ annotation_id };
            print ' (',$m,') ', ++$i, '/', scalar @$srnas;
        }

    }
}

1;

__END__
