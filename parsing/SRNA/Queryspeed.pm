package SRNA::Querycount;

use strict;
use warnings;
use DBI;
use Time::HiRes qw/ gettimeofday tv_interval /;

my $dbi = DBI->connect('dbi:mysql:database=smallrna_opt', 'kebil', 'kebil', { AutoCommit => 1 } );

$| = 1; # autoflush on

#print "No Index\n";
#$dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop` });
#$dbi->do(q{ALTER TABLE `annotations` DROP INDEX `stop_start` });
#&exe();
#
#print "start_stop\n";
#$dbi->do(q{ALTER TABLE `annotations` ADD INDEX `start_stop` ( `start` ASC, `stop` ASC ) });
#&exe();
#
#print "start\n";
#$dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop` });
#$dbi->do(q{ALTER TABLE `annotations` ADD INDEX `start` ( `start` ASC ) });
#&exe();
#
#print "stop\n";
#$dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start` });
#$dbi->do(q{ALTER TABLE `annotations` ADD INDEX `stop` ( `stop` ASC ) });
#&exe();
#
#print "stop_start\n";
#$dbi->do(q{ALTER TABLE `annotations` DROP INDEX `stop` });
#$dbi->do(q{ALTER TABLE `annotations` ADD INDEX `stop_start` ( `stop` ASC, `start` ASC ) });
#&exe();


#print "No Index\n";
#$dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
#$dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop_start` });
#&exe_srnas();
#
#print "start_stop\n";
#$dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` ASC, `stop` ASC ) });
#&exe_srnas();
#
#print "start\n";
#$dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
#$dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start` ( `start` ASC) });
#&exe_srnas();
#
#print "stop\n";
#$dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start` });
#$dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop` ( `stop` ASC) });
#&exe_srnas();
#
#print "stop_start\n";
#$dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop` });
#$dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop_start` ( `stop` ASC, `start` ASC) });
#&exe_srnas();


print "No Index\n";
$dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
$dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop_start` });
&exe_srnas();

print "start_stop DESC\n";
$dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` DESC, `stop` DESC) });
&exe_srnas();

print "start_stop ASC DESC\n";
$dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
$dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` ASC, `stop` DESC) });
&exe_srnas();

print "start_stop DESC ASC\n";
$dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
$dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` DESC, `stop` ASC) });
&exe_srnas();

print "start\n";
$dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
$dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start` ( `start` DESC) });
&exe_srnas();

print "stop\n";
$dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start` });
$dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop` ( `stop` DESC) });
&exe_srnas();

print "stop_start DESC\n";
$dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop` });
$dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop_start` ( `stop` DESC, `start` DESC) });
&exe_srnas();

print "stop_start ASC DESC\n";
$dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop_start` });
$dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop_start` ( `stop` ASC, `start` DESC) });
&exe_srnas();

print "stop_start DESC ASC\n";
$dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop_start` });
$dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop_start` ( `stop` DESC, `start` ASC) });
&exe_srnas();


sub exe {
    my @ids = (100..199);
    my @ranges = ();
    for my $i (1..100) {
        push @ranges, [ (3500 + $i*125), (4500 + $i*125) ] ;
    }

    # list one annot
    my $start = [gettimeofday()];
    my $sth = $dbi->prepare(q{ SELECT `Annotation`.`id`, `Annotation`.`accession_nr`, `Annotation`.`model_nr`, `Annotation`.`start`, `Annotation`.`stop`, `Annotation`.`strand`, `Annotation`.`chromosome_id`, `Annotation`.`type`, `Annotation`.`species_id`, `Annotation`.`seq`, `Annotation`.`comment`, `Annotation`.`source_id`, (CONCAT(`Annotation`.`accession_nr`, '.', `Annotation`.`model_nr`)) AS `Annotation__accession`, `Species`.`id`, `Species`.`full_name`, `Species`.`short_name`, `Species`.`NCBI_tax_id`, `Source`.`id`, `Source`.`name`, `Source`.`description`, `Chromosome`.`id`, `Chromosome`.`name`, `Chromosome`.`length`, `Chromosome`.`species_id` FROM `annotations` AS `Annotation` LEFT JOIN `species` AS `Species` ON (`Annotation`.`species_id` = `Species`.`id`) LEFT JOIN `sources` AS `Source` ON (`Annotation`.`source_id` = `Source`.`id`) LEFT JOIN `chromosomes` AS `Chromosome` ON (`Annotation`.`chromosome_id` = `Chromosome`.`id`) WHERE `Annotation`.`id` = ? });
    for my $id (@ids) {
        $sth->execute( $id );
    }
    my $stop = [gettimeofday()];

    print "\tlist one annot\n";
    print "\t\tTotal: " . tv_interval($start, $stop) . "s\n";
    print "\t\tq/s  : " . scalar(@ids)/tv_interval($start, $stop) . "q/s\n";

    # list range of annots
    $start = [gettimeofday()];
    $sth = $dbi->prepare(q{ SELECT `Annotation`.`id`, `Annotation`.`accession_nr`, `Annotation`.`model_nr`, `Annotation`.`start`, `Annotation`.`stop`, `Annotation`.`strand`, `Annotation`.`chromosome_id`, `Annotation`.`type`, `Annotation`.`species_id`, `Annotation`.`seq`, `Annotation`.`comment`, `Annotation`.`source_id`, (CONCAT(`Annotation`.`accession_nr`, '.', `Annotation`.`model_nr`)) AS `Annotation__accession`, `Species`.`id`, `Species`.`full_name`, `Species`.`short_name`, `Species`.`NCBI_tax_id`, `Source`.`id`, `Source`.`name`, `Source`.`description`, `Chromosome`.`id`, `Chromosome`.`name`, `Chromosome`.`length`, `Chromosome`.`species_id` FROM `annotations` AS `Annotation` LEFT JOIN `species` AS `Species` ON (`Annotation`.`species_id` = `Species`.`id`) LEFT JOIN `sources` AS `Source` ON (`Annotation`.`source_id` = `Source`.`id`) LEFT JOIN `chromosomes` AS `Chromosome` ON (`Annotation`.`chromosome_id` = `Chromosome`.`id`) WHERE `Annotation`.`start` <= ? AND `Annotation`.`stop` >= ? });
    foreach my $range (@ranges) {
        $sth->execute( @$range );
    }
    $stop = [gettimeofday()];

    print "\tlist range annots\n";
    print "\t\tTotal: " . tv_interval($start, $stop) . "s\n";
    print "\t\tq/s  : " . scalar(@ranges)/tv_interval($start, $stop) . "q/s\n";

    # list all annots
    $start = [gettimeofday()];
    $sth = $dbi->prepare(q{ SELECT `Annotation`.`id`, `Annotation`.`accession_nr`, `Annotation`.`model_nr`, `Annotation`.`start`, `Annotation`.`stop`, `Annotation`.`strand`, `Annotation`.`chromosome_id`, `Annotation`.`type`, `Annotation`.`species_id`, `Annotation`.`seq`, `Annotation`.`comment`, `Annotation`.`source_id`, (CONCAT(`Annotation`.`accession_nr`, '.', `Annotation`.`model_nr`)) AS `Annotation__accession`, `Species`.`id`, `Species`.`full_name`, `Species`.`short_name`, `Species`.`NCBI_tax_id`, `Source`.`id`, `Source`.`name`, `Source`.`description`, `Chromosome`.`id`, `Chromosome`.`name`, `Chromosome`.`length`, `Chromosome`.`species_id` FROM `annotations` AS `Annotation` LEFT JOIN `species` AS `Species` ON (`Annotation`.`species_id` = `Species`.`id`) LEFT JOIN `sources` AS `Source` ON (`Annotation`.`source_id` = `Source`.`id`) LEFT JOIN `chromosomes` AS `Chromosome` ON (`Annotation`.`chromosome_id` = `Chromosome`.`id`) });
    $sth->execute();
    $stop = [gettimeofday()];

    print "\tlist all annots\n";
    print "\t\tTotal: " . tv_interval($start, $stop) . "s\n";
    print "\t\tq/s  : " . 1/tv_interval($start, $stop) . "q/s\n";

    # count all annots
    $start = [gettimeofday()];
    $sth = $dbi->prepare(q{ SELECT COUNT(*) AS `count` FROM `annotations` AS `Annotation` WHERE `Annotation`.`start` <= ? AND `Annotation`.`stop` >= ? });
    foreach my $range (@ranges) {
        $sth->execute( @$range );
    }
    $stop = [gettimeofday()];

    print "\tcount range of annots\n";
    print "\t\tTotal: " . tv_interval($start, $stop) . "s\n";
    print "\t\tq/s  : " . scalar(@ranges)/tv_interval($start, $stop) . "q/s\n";

    # list all annots
    $start = [gettimeofday()];
    $sth = $dbi->prepare(q{ SELECT COUNT(*) AS `count` FROM `annotations` AS `Annotation` });
    $sth->execute();
    $stop = [gettimeofday()];

    print "\tcount all annots\n";
    print "\t\tTotal: " . tv_interval($start, $stop) . "s\n";
    print "\t\tq/s  : " . 1/tv_interval($start, $stop) . "q/s\n";

    print "\n";

}

sub exe_srnas {
    my @ids = (100..199);
    my @ranges = ();
    for my $i (1..100) {
        push @ranges, [ (3500 + $i*125), (4000 + $i*125) ] ;
    }

    # list one srna 
    my $start = [gettimeofday()];
    my $sth = $dbi->prepare(q{  SELECT `Srna`.`id`, `Srna`.`name`, `Srna`.`start`, `Srna`.`stop`, `Srna`.`strand`, `Srna`.`sequence_id`, `Srna`.`score`, `Srna`.`type_id`, `Srna`.`abundance`, `Srna`.`nomalized_abundance`, `Srna`.`experiment_id`, `Srna`.`chromosome_id`, `Sequence`.`id`, `Sequence`.`seq`, `Type`.`id`, `Type`.`name`, `Experiment`.`id`, `Experiment`.`name`, `Experiment`.`description`, `Experiment`.`species_id`, `Experiment`.`internal` FROM `srnas` AS `Srna` LEFT JOIN `sequences` AS `Sequence` ON (`Srna`.`sequence_id` = `Sequence`.`id`) LEFT JOIN `types` AS `Type` ON (`Srna`.`type_id` = `Type`.`id`) LEFT JOIN `experiments` AS `Experiment` ON (`Srna`.`experiment_id` = `Experiment`.`id`) WHERE `Srna`.`id` =? });
    for my $id (@ids) {
        $sth->execute( $id );
    }
    my $stop = [gettimeofday()];

    print "\tlist one srna \n";
    print "\t\tTotal: " . tv_interval($start, $stop) . "s\n";
    print "\t\tq/s  : " . scalar(@ids)/tv_interval($start, $stop) . "q/s\n";

    # list range of srnas 
    $start = [gettimeofday()];
    $sth = $dbi->prepare(q{SELECT `Srna`.`id`, `Srna`.`name`, `Srna`.`start`, `Srna`.`stop`, `Srna`.`strand`, `Srna`.`sequence_id`, `Srna`.`score`, `Srna`.`type_id`, `Srna`.`abundance`, `Srna`.`nomalized_abundance`, `Srna`.`experiment_id`, `Srna`.`chromosome_id`, `Sequence`.`id`, `Sequence`.`seq`, `Type`.`id`, `Type`.`name`, `Experiment`.`id`, `Experiment`.`name`, `Experiment`.`description`, `Experiment`.`species_id`, `Experiment`.`internal` FROM `srnas` AS `Srna` LEFT JOIN `sequences` AS `Sequence` ON (`Srna`.`sequence_id` = `Sequence`.`id`) LEFT JOIN `types` AS `Type` ON (`Srna`.`type_id` = `Type`.`id`) LEFT JOIN `experiments` AS `Experiment` ON (`Srna`.`experiment_id` = `Experiment`.`id`) WHERE `Srna`.`start` >= ? AND `Srna`.`stop` <= ? });
    foreach my $range (@ranges) {
        $sth->execute( @$range );
    }
    $stop = [gettimeofday()];

    print "\tlist range srnas\n";
    print "\t\tTotal: " . tv_interval($start, $stop) . "s\n";
    print "\t\tq/s  : " . scalar(@ranges)/tv_interval($start, $stop) . "q/s\n";

    # list all srnas 
    $start = [gettimeofday()];
    $sth = $dbi->prepare(q{SELECT `Srna`.`id`, `Srna`.`name`, `Srna`.`start`, `Srna`.`stop`, `Srna`.`strand`, `Srna`.`sequence_id`, `Srna`.`score`, `Srna`.`type_id`, `Srna`.`abundance`, `Srna`.`nomalized_abundance`, `Srna`.`experiment_id`, `Srna`.`chromosome_id`, `Sequence`.`id`, `Sequence`.`seq`, `Type`.`id`, `Type`.`name`, `Experiment`.`id`, `Experiment`.`name`, `Experiment`.`description`, `Experiment`.`species_id`, `Experiment`.`internal` FROM `srnas` AS `Srna` LEFT JOIN `sequences` AS `Sequence` ON (`Srna`.`sequence_id` = `Sequence`.`id`) LEFT JOIN `types` AS `Type` ON (`Srna`.`type_id` = `Type`.`id`) LEFT JOIN `experiments` AS `Experiment` ON (`Srna`.`experiment_id` = `Experiment`.`id`) LIMIT 500});
    $sth->execute();
    $stop = [gettimeofday()];

    print "\tlist all srnas\n";
    print "\t\tTotal: " . tv_interval($start, $stop) . "s\n";
    print "\t\tq/s  : " . 1/tv_interval($start, $stop) . "q/s\n";

    # count srnas in a range
    $start = [gettimeofday()];
    $sth = $dbi->prepare(q{SELECT COUNT(*) AS `count` FROM `srnas` AS `Srna` WHERE `Srna`.`start` >= ? AND `Srna`.`stop` <= ? });
    foreach my $range (@ranges) {
        $sth->execute( @$range );
    }
    $stop = [gettimeofday()];

    print "\tcount range of srnas\n";
    print "\t\tTotal: " . tv_interval($start, $stop) . "s\n";
    print "\t\tq/s  : " . scalar(@ranges)/tv_interval($start, $stop) . "q/s\n";

    # count all srnas 
    $start = [gettimeofday()];
    $sth = $dbi->prepare(q{SELECT COUNT(*) AS `count` FROM `srnas` AS `Srna` });
    $sth->execute();
    $stop = [gettimeofday()];

    print "\tcount all srnas\n";
    print "\t\tTotal: " . tv_interval($start, $stop) . "s\n";
    print "\t\tq/s  : " . 1/tv_interval($start, $stop) . "q/s\n";

    print "\n";
}

1;

__END__

=head1 SYNOPSIS

Test different indexing strategies on annotations and srnas
