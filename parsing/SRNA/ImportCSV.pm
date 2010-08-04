package SRNA::ImportCSV;

use strict;
use warnings;

&run() unless caller();

sub run {
    my $count = `wc -l $ARGV[0]`;
    ($count) = split /\s/, $count; 
    my $c = 0;

    while ($c++ < $count) {
        my @command = ("mysqlimport","-r","-L","--ignore-lines","$c","-u","kebil","-pkebil","--fields-enclosed-by","\\'","smallrna_opt","$ARGV[0]");
        system(@command);
        if ($? == -1) {
            die "Failed to execute: $!\n";
        }
        elsif ($? & 127) {
            warn 'Error is on line ' . $c + 1;
            die sprintf "Child died with signal %d, %s coredump\n",
            ($? & 127), ($? & 128) ? 'with' : 'without';
        }
        elsif ($? >> 8 != 0) {
            warn 'Error is on line ' . $c + 1;
            die sprintf "Child exited with value %d\n", $? >> 8;
        }
    }
}
