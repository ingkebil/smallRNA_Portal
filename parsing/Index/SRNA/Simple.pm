package Index::SRNA::Simple;

use strict;
use warnings;
use DBI;
use Index::Test;

my $dbi = $Index::Test::dbi;

$| = 1; # autoflush on

# test for the srnas
{
    my @ids = (100..199);
    my @ranges = ();
    for my $i (1..100) {
        push @ranges, [ (3500 + $i*125), (4000 + $i*125) ] ;
    }

    my %qs = (
        'list one srna' => {
            q => q{  SELECT `Srna`.`id`, `Srna`.`name`, `Srna`.`start`, `Srna`.`stop`, `Srna`.`strand`, `Srna`.`sequence_id`, `Srna`.`score`, `Srna`.`type_id`, `Srna`.`abundance`, `Srna`.`normalized_abundance`, `Srna`.`experiment_id`, `Srna`.`chromosome_id`, `Sequence`.`id`, `Sequence`.`seq`, `Type`.`id`, `Type`.`name`, `Experiment`.`id`, `Experiment`.`name`, `Experiment`.`description`, `Experiment`.`species_id`, `Experiment`.`internal` FROM `srnas` AS `Srna` LEFT JOIN `sequences` AS `Sequence` ON (`Srna`.`sequence_id` = `Sequence`.`id`) LEFT JOIN `types` AS `Type` ON (`Srna`.`type_id` = `Type`.`id`) LEFT JOIN `experiments` AS `Experiment` ON (`Srna`.`experiment_id` = `Experiment`.`id`) WHERE `Srna`.`id` =? },
            data => \@ids,
        },
        'list range srnas' => {
            q =>q{SELECT `Srna`.`id`, `Srna`.`name`, `Srna`.`start`, `Srna`.`stop`, `Srna`.`strand`, `Srna`.`sequence_id`, `Srna`.`score`, `Srna`.`type_id`, `Srna`.`abundance`, `Srna`.`normalized_abundance`, `Srna`.`experiment_id`, `Srna`.`chromosome_id`, `Sequence`.`id`, `Sequence`.`seq`, `Type`.`id`, `Type`.`name`, `Experiment`.`id`, `Experiment`.`name`, `Experiment`.`description`, `Experiment`.`species_id`, `Experiment`.`internal` FROM `srnas` AS `Srna` LEFT JOIN `sequences` AS `Sequence` ON (`Srna`.`sequence_id` = `Sequence`.`id`) LEFT JOIN `types` AS `Type` ON (`Srna`.`type_id` = `Type`.`id`) LEFT JOIN `experiments` AS `Experiment` ON (`Srna`.`experiment_id` = `Experiment`.`id`) WHERE `Srna`.`start` >= ? AND `Srna`.`stop` <= ? AND chromosome_id = 7 },
            data => \@ranges,
        },
        'list all srnas' => {
            q => q{SELECT `Srna`.`id`, `Srna`.`name`, `Srna`.`start`, `Srna`.`stop`, `Srna`.`strand`, `Srna`.`sequence_id`, `Srna`.`score`, `Srna`.`type_id`, `Srna`.`abundance`, `Srna`.`normalized_abundance`, `Srna`.`experiment_id`, `Srna`.`chromosome_id`, `Sequence`.`id`, `Sequence`.`seq`, `Type`.`id`, `Type`.`name`, `Experiment`.`id`, `Experiment`.`name`, `Experiment`.`description`, `Experiment`.`species_id`, `Experiment`.`internal` FROM `srnas` AS `Srna` LEFT JOIN `sequences` AS `Sequence` ON (`Srna`.`sequence_id` = `Sequence`.`id`) LEFT JOIN `types` AS `Type` ON (`Srna`.`type_id` = `Type`.`id`) LEFT JOIN `experiments` AS `Experiment` ON (`Srna`.`experiment_id` = `Experiment`.`id`) WHERE chromosome_id = 7 LIMIT 500},
            data => [],
        },
        'count range srnas' => {
            q =>q{SELECT COUNT(*) AS `count` FROM `srnas` AS `Srna` WHERE `Srna`.`start` >= ? AND `Srna`.`stop` <= ? AND chromosome_id = 7 },
            data => \@ranges,
        },
        'count all srnas' => {
            q =>q{SELECT COUNT(*) AS `count` FROM `srnas` AS `Srna` WHERE chromosome_id = 7 },
            data => [],
        },
    );

    print "^ ", join "^", keys %qs;

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop_start` });
    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop` });
    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start` });
    &Index::Test::exe('no index', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` ASC, `stop` ASC ) });
    &Index::Test::exe('start_stop', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` ASC) });
    &Index::Test::exe('start', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `stop` ASC) });
    &Index::Test::exe('stop', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `stop` ASC, `start` ASC) });
    &Index::Test::exe('stop_start', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` DESC, `stop` DESC) });
    &Index::Test::exe('start_stop DESC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` ASC, `stop` DESC) });
    &Index::Test::exe('start_stop ASC DESC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` DESC, `stop` ASC) });
    &Index::Test::exe('start_stop DESC ASC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` DESC) });
    &Index::Test::exe('start DESC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `stop` DESC) });
    &Index::Test::exe('stop', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `stop` DESC, `start` DESC) });
    &Index::Test::exe('stop_start DESC DESC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `stop` ASC, `start` DESC) });
    &Index::Test::exe('stop_start DESC ASC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `stop` DESC, `start` ASC) });
    &Index::Test::exe('stop_start DESC ASC', \%qs);

}

# test for the srnas with double indIndex::Test::exes
{
    my @ids = (100..199);
    my @ranges = ();
    for my $i (1..100) {
        push @ranges, [ (3500 + $i*125), (4000 + $i*125) ] ;
    }

    my %qs = (
        'list one srna' => {
            q => q{  SELECT `Srna`.`id`, `Srna`.`name`, `Srna`.`start`, `Srna`.`stop`, `Srna`.`strand`, `Srna`.`sequence_id`, `Srna`.`score`, `Srna`.`type_id`, `Srna`.`abundance`, `Srna`.`normalized_abundance`, `Srna`.`experiment_id`, `Srna`.`chromosome_id`, `Sequence`.`id`, `Sequence`.`seq`, `Type`.`id`, `Type`.`name`, `Experiment`.`id`, `Experiment`.`name`, `Experiment`.`description`, `Experiment`.`species_id`, `Experiment`.`internal` FROM `srnas` AS `Srna` LEFT JOIN `sequences` AS `Sequence` ON (`Srna`.`sequence_id` = `Sequence`.`id`) LEFT JOIN `types` AS `Type` ON (`Srna`.`type_id` = `Type`.`id`) LEFT JOIN `experiments` AS `Experiment` ON (`Srna`.`experiment_id` = `Experiment`.`id`) WHERE `Srna`.`id` =? },
            data => \@ids,
        },
        'list range srnas' => {
            q =>q{SELECT `Srna`.`id`, `Srna`.`name`, `Srna`.`start`, `Srna`.`stop`, `Srna`.`strand`, `Srna`.`sequence_id`, `Srna`.`score`, `Srna`.`type_id`, `Srna`.`abundance`, `Srna`.`normalized_abundance`, `Srna`.`experiment_id`, `Srna`.`chromosome_id`, `Sequence`.`id`, `Sequence`.`seq`, `Type`.`id`, `Type`.`name`, `Experiment`.`id`, `Experiment`.`name`, `Experiment`.`description`, `Experiment`.`species_id`, `Experiment`.`internal` FROM `srnas` AS `Srna` LEFT JOIN `sequences` AS `Sequence` ON (`Srna`.`sequence_id` = `Sequence`.`id`) LEFT JOIN `types` AS `Type` ON (`Srna`.`type_id` = `Type`.`id`) LEFT JOIN `experiments` AS `Experiment` ON (`Srna`.`experiment_id` = `Experiment`.`id`) WHERE `Srna`.`start` >= ? AND `Srna`.`stop` <= ? AND chromosome_id = 7 },
            data => \@ranges,
        },
        'list all srnas' => {
            q => q{SELECT `Srna`.`id`, `Srna`.`name`, `Srna`.`start`, `Srna`.`stop`, `Srna`.`strand`, `Srna`.`sequence_id`, `Srna`.`score`, `Srna`.`type_id`, `Srna`.`abundance`, `Srna`.`normalized_abundance`, `Srna`.`experiment_id`, `Srna`.`chromosome_id`, `Sequence`.`id`, `Sequence`.`seq`, `Type`.`id`, `Type`.`name`, `Experiment`.`id`, `Experiment`.`name`, `Experiment`.`description`, `Experiment`.`species_id`, `Experiment`.`internal` FROM `srnas` AS `Srna` LEFT JOIN `sequences` AS `Sequence` ON (`Srna`.`sequence_id` = `Sequence`.`id`) LEFT JOIN `types` AS `Type` ON (`Srna`.`type_id` = `Type`.`id`) LEFT JOIN `experiments` AS `Experiment` ON (`Srna`.`experiment_id` = `Experiment`.`id`) WHERE chromosome_id = 7 LIMIT 500},
            data => [],
        },
        'count range srnas' => {
            q =>q{SELECT COUNT(*) AS `count` FROM `srnas` AS `Srna` WHERE `Srna`.`start` >= ? AND `Srna`.`stop` <= ? AND chromosome_id = 7 },
            data => \@ranges,
        },
        'count all srnas' => {
            q =>q{SELECT COUNT(*) AS `count` FROM `srnas` AS `Srna` WHERE chromosome_id = 7 },
            data => [],
        },
    );


    print "^ ", join "^", keys %qs;

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop_start` });
    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop` });
    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start` });
    &Index::Test::exe('no index', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` ASC, `stop` ASC, `chromosome_id` ASC ) });
    &Index::Test::exe('start_stop', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` ASC, `chromosome_id` ASC) });
    &Index::Test::exe('start', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `stop` ASC, `chromosome_id` ASC) });
    &Index::Test::exe('stop', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `stop` ASC, `start` ASC, `chromosome_id` ASC) });
    &Index::Test::exe('stop_start', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` DESC, `stop` DESC, `chromosome_id` ASC) });
    &Index::Test::exe('start_stop DESC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` ASC, `stop` DESC, `chromosome_id` ASC) });
    &Index::Test::exe('start_stop ASC DESC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` DESC, `stop` ASC, `chromosome_id` ASC) });
    &Index::Test::exe('start_stop DESC ASC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` DESC, `chromosome_id` ASC) });
    &Index::Test::exe('start DESC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `stop` DESC, `chromosome_id` ASC) });
    &Index::Test::exe('stop', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `stop` DESC, `start` DESC, `chromosome_id` ASC) });
    &Index::Test::exe('stop_start DESC DESC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `stop` ASC, `start` DESC, `chromosome_id` ASC) });
    &Index::Test::exe('stop_start ASC DESC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `stop` DESC, `start` ASC, `chromosome_id` ASC) });
    &Index::Test::exe('stop_start DESC ASC', \%qs);

}

1;

__END__

=head1 SYNOPSIS

Test different indexing strategies on srnas
