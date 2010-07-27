#!usr/bin/perl
package SRNA::Parseall_degr;

use strict;
use warnings;


for i in `ls /mnt/degradome/arabidopsis/D-N/maps/`                                                ~/git/smallRNA/parsing
do perl -MVi::QuickFix /home/billiau/git/smallRNA/parsing/TPlot/CSV2sRNA.pm --experiment_id 10 --speciesid 1 --path ~/tmp/ /mnt/degradome/arabidopsis/D-N/maps/$i

