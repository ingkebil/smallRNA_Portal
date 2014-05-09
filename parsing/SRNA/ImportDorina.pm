#!/usr/bin/perl
package SRNA::ImportDorina;

use strict;
use warnings;
use DBI;
use Settings;
use SRNA::DBAbstract;

my $dbi = DBI->connect('dbi:mysql:database=microRNA_Database;host=dorina', 'lenz');
