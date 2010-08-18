package SRNA::Querycount;

use strict;
use warnings;
use DBI;
use Index::Test;

my $dbi = $Index::Test::dbi;

$| = 1; # autoflush on

# test conditions for the annotations: no chrom_id
{
    my @ids = (100..199);
    my @ranges = ();
    for my $i (1..100) {
        push @ranges, [ (3500 + $i*125), (4500 + $i*125) ] ;
    }

    my %qs = (
        'list one annot' => { 
            q => q{ SELECT `Annotation`.`id`, `Annotation`.`accession_nr`, `Annotation`.`model_nr`, `Annotation`.`start`, `Annotation`.`stop`, `Annotation`.`strand`, `Annotation`.`chromosome_id`, `Annotation`.`type`, `Annotation`.`species_id`, `Annotation`.`seq`, `Annotation`.`comment`, `Annotation`.`source_id`, (CONCAT(`Annotation`.`accession_nr`, '.', `Annotation`.`model_nr`)) AS `Annotation__accession`, `Species`.`id`, `Species`.`full_name`, `Species`.`short_name`, `Species`.`NCBI_tax_id`, `Source`.`id`, `Source`.`name`, `Source`.`description`, `Chromosome`.`id`, `Chromosome`.`name`, `Chromosome`.`length`, `Chromosome`.`species_id` FROM `annotations` AS `Annotation` LEFT JOIN `species` AS `Species` ON (`Annotation`.`species_id` = `Species`.`id`) LEFT JOIN `sources` AS `Source` ON (`Annotation`.`source_id` = `Source`.`id`) LEFT JOIN `chromosomes` AS `Chromosome` ON (`Annotation`.`chromosome_id` = `Chromosome`.`id`) WHERE `Annotation`.`id` = ? },
            data => \@ids, 
        },
        'list range of annots' => {
            q => q{ SELECT `Annotation`.`id`, `Annotation`.`accession_nr`, `Annotation`.`model_nr`, `Annotation`.`start`, `Annotation`.`stop`, `Annotation`.`strand`, `Annotation`.`chromosome_id`, `Annotation`.`type`, `Annotation`.`species_id`, `Annotation`.`seq`, `Annotation`.`comment`, `Annotation`.`source_id`, (CONCAT(`Annotation`.`accession_nr`, '.', `Annotation`.`model_nr`)) AS `Annotation__accession`, `Species`.`id`, `Species`.`full_name`, `Species`.`short_name`, `Species`.`NCBI_tax_id`, `Source`.`id`, `Source`.`name`, `Source`.`description`, `Chromosome`.`id`, `Chromosome`.`name`, `Chromosome`.`length`, `Chromosome`.`species_id` FROM `annotations` AS `Annotation` LEFT JOIN `species` AS `Species` ON (`Annotation`.`species_id` = `Species`.`id`) LEFT JOIN `sources` AS `Source` ON (`Annotation`.`source_id` = `Source`.`id`) LEFT JOIN `chromosomes` AS `Chromosome` ON (`Annotation`.`chromosome_id` = `Chromosome`.`id`) WHERE `Annotation`.`start` <= ? AND `Annotation`.`stop` >= ? },
            data => \@ranges,
        },
        'list all annots' => {
            q => q{ SELECT `Annotation`.`id`, `Annotation`.`accession_nr`, `Annotation`.`model_nr`, `Annotation`.`start`, `Annotation`.`stop`, `Annotation`.`strand`, `Annotation`.`chromosome_id`, `Annotation`.`type`, `Annotation`.`species_id`, `Annotation`.`seq`, `Annotation`.`comment`, `Annotation`.`source_id`, (CONCAT(`Annotation`.`accession_nr`, '.', `Annotation`.`model_nr`)) AS `Annotation__accession`, `Species`.`id`, `Species`.`full_name`, `Species`.`short_name`, `Species`.`NCBI_tax_id`, `Source`.`id`, `Source`.`name`, `Source`.`description`, `Chromosome`.`id`, `Chromosome`.`name`, `Chromosome`.`length`, `Chromosome`.`species_id` FROM `annotations` AS `Annotation` LEFT JOIN `species` AS `Species` ON (`Annotation`.`species_id` = `Species`.`id`) LEFT JOIN `sources` AS `Source` ON (`Annotation`.`source_id` = `Source`.`id`) LEFT JOIN `chromosomes` AS `Chromosome` ON (`Annotation`.`chromosome_id` = `Chromosome`.`id`) },
            data => [],
        },
        'count range annots', => {
            q => q{ SELECT COUNT(*) AS `count` FROM `annotations` AS `Annotation` WHERE `Annotation`.`start` <= ? AND `Annotation`.`stop` >= ? },
            data => \@ranges,
        },
        'count all annots' => {
            q => q{ SELECT COUNT(*) AS `count` FROM `annotations` AS `Annotation` },
            data => [],
        }
    );

    print join '^', keys %qs;

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop` });
    &Index::Test::exe('No Index', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` ADD INDEX `start_stop` ( `start` ASC, `stop` ASC ) });
    &Index::Test::exe('start_stop', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` ( `start` ASC ) });
    &Index::Test::exe('start', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` ( `stop` ASC ) });
    &Index::Test::exe('stop', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` ( `stop` ASC, `start` ASC ) });
    &Index::Test::exe('stop_start', \%qs);
}

# annot with chromosome id included and a seperate chrom index
{
    my @ids = (100..199);
    my @ranges = ();
    for my $i (1..100) {
        push @ranges, [ (3500 + $i*125), (4500 + $i*125), $i % 7 ] ; # start, stop, chr_id
    }

    my %qs = (
        'list one annot' => { 
            q => q{ SELECT `Annotation`.`id`, `Annotation`.`accession_nr`, `Annotation`.`model_nr`, `Annotation`.`start`, `Annotation`.`stop`, `Annotation`.`strand`, `Annotation`.`chromosome_id`, `Annotation`.`type`, `Annotation`.`species_id`, `Annotation`.`seq`, `Annotation`.`comment`, `Annotation`.`source_id`, (CONCAT(`Annotation`.`accession_nr`, '.', `Annotation`.`model_nr`)) AS `Annotation__accession`, `Species`.`id`, `Species`.`full_name`, `Species`.`short_name`, `Species`.`NCBI_tax_id`, `Source`.`id`, `Source`.`name`, `Source`.`description`, `Chromosome`.`id`, `Chromosome`.`name`, `Chromosome`.`length`, `Chromosome`.`species_id` FROM `annotations` AS `Annotation` LEFT JOIN `species` AS `Species` ON (`Annotation`.`species_id` = `Species`.`id`) LEFT JOIN `sources` AS `Source` ON (`Annotation`.`source_id` = `Source`.`id`) LEFT JOIN `chromosomes` AS `Chromosome` ON (`Annotation`.`chromosome_id` = `Chromosome`.`id`) WHERE `Annotation`.`id` = ? },
            data => \@ids, 
        },
        'list range of annots' => {
            q => q{ SELECT `Annotation`.`id`, `Annotation`.`accession_nr`, `Annotation`.`model_nr`, `Annotation`.`start`, `Annotation`.`stop`, `Annotation`.`strand`, `Annotation`.`chromosome_id`, `Annotation`.`type`, `Annotation`.`species_id`, `Annotation`.`seq`, `Annotation`.`comment`, `Annotation`.`source_id`, (CONCAT(`Annotation`.`accession_nr`, '.', `Annotation`.`model_nr`)) AS `Annotation__accession`, `Species`.`id`, `Species`.`full_name`, `Species`.`short_name`, `Species`.`NCBI_tax_id`, `Source`.`id`, `Source`.`name`, `Source`.`description`, `Chromosome`.`id`, `Chromosome`.`name`, `Chromosome`.`length`, `Chromosome`.`species_id` FROM `annotations` AS `Annotation` LEFT JOIN `species` AS `Species` ON (`Annotation`.`species_id` = `Species`.`id`) LEFT JOIN `sources` AS `Source` ON (`Annotation`.`source_id` = `Source`.`id`) LEFT JOIN `chromosomes` AS `Chromosome` ON (`Annotation`.`chromosome_id` = `Chromosome`.`id`) WHERE `Annotation`.`start` <= ? AND `Annotation`.`stop` >= ? AND `Annotation`.`chromosome_id` = ? },
            data => \@ranges,
        },
        'list all annots' => {
            q => q{ SELECT `Annotation`.`id`, `Annotation`.`accession_nr`, `Annotation`.`model_nr`, `Annotation`.`start`, `Annotation`.`stop`, `Annotation`.`strand`, `Annotation`.`chromosome_id`, `Annotation`.`type`, `Annotation`.`species_id`, `Annotation`.`seq`, `Annotation`.`comment`, `Annotation`.`source_id`, (CONCAT(`Annotation`.`accession_nr`, '.', `Annotation`.`model_nr`)) AS `Annotation__accession`, `Species`.`id`, `Species`.`full_name`, `Species`.`short_name`, `Species`.`NCBI_tax_id`, `Source`.`id`, `Source`.`name`, `Source`.`description`, `Chromosome`.`id`, `Chromosome`.`name`, `Chromosome`.`length`, `Chromosome`.`species_id` FROM `annotations` AS `Annotation` LEFT JOIN `species` AS `Species` ON (`Annotation`.`species_id` = `Species`.`id`) LEFT JOIN `sources` AS `Source` ON (`Annotation`.`source_id` = `Source`.`id`) LEFT JOIN `chromosomes` AS `Chromosome` ON (`Annotation`.`chromosome_id` = `Chromosome`.`id`) },
            data => [],
        },
        'count range annots', => {
            q => q{ SELECT COUNT(*) AS `count` FROM `annotations` AS `Annotation` WHERE `Annotation`.`start` <= ? AND `Annotation`.`stop` >= ? AND `Annotation`.`chromosome_id` = ? },
            data => \@ranges,
        },
        'count all annots' => {
            q => q{ SELECT COUNT(*) AS `count` FROM `annotations` AS `Annotation` },
            data => [],
        }
    );

    print join '^', keys %qs;

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop` });
    &Index::Test::exe('No Index', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` (`start` ASC ) });
    &Index::Test::exe('start', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` (`start` DESC ) });
    &Index::Test::exe('startD', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` (`start` ASC, `stop` ASC ) });
    &Index::Test::exe('start_stop', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` (`start` ASC, `stop` DESC) });
    &Index::Test::exe('startA_stopD', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` (`start` DESC, `stop` ASC ) });
    &Index::Test::exe('startD_stopA', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` (`start` DESC, `stop` DESC ) });
    &Index::Test::exe('startD_stopD', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` (`stop` ASC ) });
    &Index::Test::exe('stop', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` (`stop` DESC ) });
    &Index::Test::exe('stopD', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` (`stop` ASC, `start` ASC ) });
    &Index::Test::exe('stop_start', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` (`stop` ASC, `start` DESC) });
    &Index::Test::exe('stopA_startD', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` (`stop` DESC, `start` ASC ) });
    &Index::Test::exe('stopD_startA', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` (`stop` DESC, `start` DESC ) });
    &Index::Test::exe('stopD_startD', \%qs);
}

# combined indexes: chr_id + stop, stop_start
{
    my @ids = (100..199);
    my @ranges = ();
    for my $i (1..100) {
        push @ranges, [ $i % 7, (4500 + $i*125), (3500 + $i*125) ] ; # chr_id, stop, start
    }
my %qs = ( 'list one annot' => { q => q{ SELECT `Annotation`.`id`, `Annotation`.`accession_nr`, `Annotation`.`model_nr`, `Annotation`.`start`, `Annotation`.`stop`, `Annotation`.`strand`, `Annotation`.`chromosome_id`, `Annotation`.`type`, `Annotation`.`species_id`, `Annotation`.`seq`, `Annotation`.`comment`, `Annotation`.`source_id`, (CONCAT(`Annotation`.`accession_nr`, '.', `Annotation`.`model_nr`)) AS `Annotation__accession`, `Species`.`id`, `Species`.`full_name`, `Species`.`short_name`, `Species`.`NCBI_tax_id`, `Source`.`id`, `Source`.`name`, `Source`.`description`, `Chromosome`.`id`, `Chromosome`.`name`, `Chromosome`.`length`, `Chromosome`.`species_id` FROM `annotations` AS `Annotation` LEFT JOIN `species` AS `Species` ON (`Annotation`.`species_id` = `Species`.`id`) LEFT JOIN `sources` AS `Source` ON (`Annotation`.`source_id` = `Source`.`id`) LEFT JOIN `chromosomes` AS `Chromosome` ON (`Annotation`.`chromosome_id` = `Chromosome`.`id`) WHERE `Annotation`.`id` = ? },
            data => \@ids, 
        },
        'list range of annots' => {
            q => q{ SELECT `Annotation`.`id`, `Annotation`.`accession_nr`, `Annotation`.`model_nr`, `Annotation`.`start`, `Annotation`.`stop`, `Annotation`.`strand`, `Annotation`.`chromosome_id`, `Annotation`.`type`, `Annotation`.`species_id`, `Annotation`.`seq`, `Annotation`.`comment`, `Annotation`.`source_id`, (CONCAT(`Annotation`.`accession_nr`, '.', `Annotation`.`model_nr`)) AS `Annotation__accession`, `Species`.`id`, `Species`.`full_name`, `Species`.`short_name`, `Species`.`NCBI_tax_id`, `Source`.`id`, `Source`.`name`, `Source`.`description`, `Chromosome`.`id`, `Chromosome`.`name`, `Chromosome`.`length`, `Chromosome`.`species_id` FROM `annotations` AS `Annotation` LEFT JOIN `species` AS `Species` ON (`Annotation`.`species_id` = `Species`.`id`) LEFT JOIN `sources` AS `Source` ON (`Annotation`.`source_id` = `Source`.`id`) LEFT JOIN `chromosomes` AS `Chromosome` ON (`Annotation`.`chromosome_id` = `Chromosome`.`id`) WHERE `Annotation`.`chromosome_id` = ? AND `Annotation`.`stop` >= ? AND `Annotation`.`start` <= ?  },
            data => \@ranges,
        },
        'list all annots' => {
            q => q{ SELECT `Annotation`.`id`, `Annotation`.`accession_nr`, `Annotation`.`model_nr`, `Annotation`.`start`, `Annotation`.`stop`, `Annotation`.`strand`, `Annotation`.`chromosome_id`, `Annotation`.`type`, `Annotation`.`species_id`, `Annotation`.`seq`, `Annotation`.`comment`, `Annotation`.`source_id`, (CONCAT(`Annotation`.`accession_nr`, '.', `Annotation`.`model_nr`)) AS `Annotation__accession`, `Species`.`id`, `Species`.`full_name`, `Species`.`short_name`, `Species`.`NCBI_tax_id`, `Source`.`id`, `Source`.`name`, `Source`.`description`, `Chromosome`.`id`, `Chromosome`.`name`, `Chromosome`.`length`, `Chromosome`.`species_id` FROM `annotations` AS `Annotation` LEFT JOIN `species` AS `Species` ON (`Annotation`.`species_id` = `Species`.`id`) LEFT JOIN `sources` AS `Source` ON (`Annotation`.`source_id` = `Source`.`id`) LEFT JOIN `chromosomes` AS `Chromosome` ON (`Annotation`.`chromosome_id` = `Chromosome`.`id`) },
            data => [],
        },
        'count range annots', => {
            q => q{ SELECT COUNT(*) AS `count` FROM `annotations` AS `Annotation` WHERE `Annotation`.`chromosome_id` = ? AND `Annotation`.`stop` >= ? AND `Annotation`.`start` <= ?  },
            data => \@ranges,
        },
        'count all annots' => {
            q => q{ SELECT COUNT(*) AS `count` FROM `annotations` AS `Annotation` },
            data => [],
        }
    );

    print join '^', keys %qs;

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop` });
    &Index::Test::exe('No Index', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, DROP INDEX `chrom`, ADD INDEX `start_stop` (`chromosome_id` ASC, `stop` ASC ) });
    &Index::Test::exe('chrom_stop', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` (`chromosome_id` ASC, `stop` DESC ) });
    &Index::Test::exe('chrom_stopD', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` (`chromosome_id` ASC, `stop` ASC, `start` ASC ) });
    &Index::Test::exe('chrom_stop_start', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` (`chromosome_id` ASC, `stop` ASC, `start` DESC) });
    &Index::Test::exe('chrom_stopA_startD', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` (`chromosome_id` ASC, `stop` DESC, `start` ASC ) });
    &Index::Test::exe('chrom_stopD_startA', \%qs);

    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop`, ADD INDEX `start_stop` (`chromosome_id` ASC, `stop` DESC, `start` DESC ) });
    &Index::Test::exe('chrom_stopD_startD', \%qs);
}

1;

__END__

=head1 SYNOPSIS

Test different indexing strategies on annotations and srnas
