package SRNA::Querycount;

use strict;
use warnings;
use DBI;
use Time::HiRes qw/ gettimeofday tv_interval /;
use Data::Dumper;

my $dbi = DBI->connect('dbi:mysql:database=smallrna_opt', 'kebil', 'kebil', { AutoCommit => 1 } );
# autocommit on to have a reconnect when the connection should time out

$| = 1; # autoflush on

# test conditions for the annotations
#{
#    my @ids = (100..199);
#    my @ranges = ();
#    for my $i (1..100) {
#        push @ranges, [ (3500 + $i*125), (4500 + $i*125) ] ;
#    }
#
#    my %qs = (
#        'list one annot' => { 
#            q => q{ SELECT `Annotation`.`id`, `Annotation`.`accession_nr`, `Annotation`.`model_nr`, `Annotation`.`start`, `Annotation`.`stop`, `Annotation`.`strand`, `Annotation`.`chromosome_id`, `Annotation`.`type`, `Annotation`.`species_id`, `Annotation`.`seq`, `Annotation`.`comment`, `Annotation`.`source_id`, (CONCAT(`Annotation`.`accession_nr`, '.', `Annotation`.`model_nr`)) AS `Annotation__accession`, `Species`.`id`, `Species`.`full_name`, `Species`.`short_name`, `Species`.`NCBI_tax_id`, `Source`.`id`, `Source`.`name`, `Source`.`description`, `Chromosome`.`id`, `Chromosome`.`name`, `Chromosome`.`length`, `Chromosome`.`species_id` FROM `annotations` AS `Annotation` LEFT JOIN `species` AS `Species` ON (`Annotation`.`species_id` = `Species`.`id`) LEFT JOIN `sources` AS `Source` ON (`Annotation`.`source_id` = `Source`.`id`) LEFT JOIN `chromosomes` AS `Chromosome` ON (`Annotation`.`chromosome_id` = `Chromosome`.`id`) WHERE `Annotation`.`id` = ? },
#            data => \@ids, 
#        },
#        'list range of annots' => {
#            q => q{ SELECT `Annotation`.`id`, `Annotation`.`accession_nr`, `Annotation`.`model_nr`, `Annotation`.`start`, `Annotation`.`stop`, `Annotation`.`strand`, `Annotation`.`chromosome_id`, `Annotation`.`type`, `Annotation`.`species_id`, `Annotation`.`seq`, `Annotation`.`comment`, `Annotation`.`source_id`, (CONCAT(`Annotation`.`accession_nr`, '.', `Annotation`.`model_nr`)) AS `Annotation__accession`, `Species`.`id`, `Species`.`full_name`, `Species`.`short_name`, `Species`.`NCBI_tax_id`, `Source`.`id`, `Source`.`name`, `Source`.`description`, `Chromosome`.`id`, `Chromosome`.`name`, `Chromosome`.`length`, `Chromosome`.`species_id` FROM `annotations` AS `Annotation` LEFT JOIN `species` AS `Species` ON (`Annotation`.`species_id` = `Species`.`id`) LEFT JOIN `sources` AS `Source` ON (`Annotation`.`source_id` = `Source`.`id`) LEFT JOIN `chromosomes` AS `Chromosome` ON (`Annotation`.`chromosome_id` = `Chromosome`.`id`) WHERE `Annotation`.`start` <= ? AND `Annotation`.`stop` >= ? },
#            data => \@ranges,
#        },
#        'list all annots' => {
#            q => q{ SELECT `Annotation`.`id`, `Annotation`.`accession_nr`, `Annotation`.`model_nr`, `Annotation`.`start`, `Annotation`.`stop`, `Annotation`.`strand`, `Annotation`.`chromosome_id`, `Annotation`.`type`, `Annotation`.`species_id`, `Annotation`.`seq`, `Annotation`.`comment`, `Annotation`.`source_id`, (CONCAT(`Annotation`.`accession_nr`, '.', `Annotation`.`model_nr`)) AS `Annotation__accession`, `Species`.`id`, `Species`.`full_name`, `Species`.`short_name`, `Species`.`NCBI_tax_id`, `Source`.`id`, `Source`.`name`, `Source`.`description`, `Chromosome`.`id`, `Chromosome`.`name`, `Chromosome`.`length`, `Chromosome`.`species_id` FROM `annotations` AS `Annotation` LEFT JOIN `species` AS `Species` ON (`Annotation`.`species_id` = `Species`.`id`) LEFT JOIN `sources` AS `Source` ON (`Annotation`.`source_id` = `Source`.`id`) LEFT JOIN `chromosomes` AS `Chromosome` ON (`Annotation`.`chromosome_id` = `Chromosome`.`id`) },
#            data => [],
#        },
#        'count range annots', => {
#            q => q{ SELECT COUNT(*) AS `count` FROM `annotations` AS `Annotation` WHERE `Annotation`.`start` <= ? AND `Annotation`.`stop` >= ? },
#            data => \@ranges,
#        },
#        'count all annots' => {
#            q => q{ SELECT COUNT(*) AS `count` FROM `annotations` AS `Annotation` },
#            data => [],
#        }
#    );
#
#    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop` });
#    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `stop_start` });
#    &exe('No Index', \%qs);
#
#    $dbi->do(q{ALTER TABLE `annotations` ADD INDEX `start_stop` ( `start` ASC, `stop` ASC ) });
#    &exe('start_stop', \%qs);
#
#    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start_stop` });
#    $dbi->do(q{ALTER TABLE `annotations` ADD INDEX `start` ( `start` ASC ) });
#    &exe('start', \%qs);
#
#    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `start` });
#    $dbi->do(q{ALTER TABLE `annotations` ADD INDEX `stop` ( `stop` ASC ) });
#    &exe('stop', \%qs);
#
#    $dbi->do(q{ALTER TABLE `annotations` DROP INDEX `stop` });
#    $dbi->do(q{ALTER TABLE `annotations` ADD INDEX `stop_start` ( `stop` ASC, `start` ASC ) });
#    &exe('stop_start', \%qs);
#}


# test for the srnas
#{
#    my @ids = (100..199);
#    my @ranges = ();
#    for my $i (1..100) {
#        push @ranges, [ (3500 + $i*125), (4000 + $i*125) ] ;
#    }
#
#    my %qs = (
#        'list one srna' => {
#            q => q{  SELECT `Srna`.`id`, `Srna`.`name`, `Srna`.`start`, `Srna`.`stop`, `Srna`.`strand`, `Srna`.`sequence_id`, `Srna`.`score`, `Srna`.`type_id`, `Srna`.`abundance`, `Srna`.`nomalized_abundance`, `Srna`.`experiment_id`, `Srna`.`chromosome_id`, `Sequence`.`id`, `Sequence`.`seq`, `Type`.`id`, `Type`.`name`, `Experiment`.`id`, `Experiment`.`name`, `Experiment`.`description`, `Experiment`.`species_id`, `Experiment`.`internal` FROM `srnas` AS `Srna` LEFT JOIN `sequences` AS `Sequence` ON (`Srna`.`sequence_id` = `Sequence`.`id`) LEFT JOIN `types` AS `Type` ON (`Srna`.`type_id` = `Type`.`id`) LEFT JOIN `experiments` AS `Experiment` ON (`Srna`.`experiment_id` = `Experiment`.`id`) WHERE `Srna`.`id` =? },
#            data => \@ids,
#        },
#        'list range srnas' => {
#            q =>q{SELECT `Srna`.`id`, `Srna`.`name`, `Srna`.`start`, `Srna`.`stop`, `Srna`.`strand`, `Srna`.`sequence_id`, `Srna`.`score`, `Srna`.`type_id`, `Srna`.`abundance`, `Srna`.`nomalized_abundance`, `Srna`.`experiment_id`, `Srna`.`chromosome_id`, `Sequence`.`id`, `Sequence`.`seq`, `Type`.`id`, `Type`.`name`, `Experiment`.`id`, `Experiment`.`name`, `Experiment`.`description`, `Experiment`.`species_id`, `Experiment`.`internal` FROM `srnas` AS `Srna` LEFT JOIN `sequences` AS `Sequence` ON (`Srna`.`sequence_id` = `Sequence`.`id`) LEFT JOIN `types` AS `Type` ON (`Srna`.`type_id` = `Type`.`id`) LEFT JOIN `experiments` AS `Experiment` ON (`Srna`.`experiment_id` = `Experiment`.`id`) WHERE `Srna`.`start` >= ? AND `Srna`.`stop` <= ? AND chromosome_id = 7 },
#            data => \@ranges,
#        },
#        'list all srnas' => {
#            q => q{SELECT `Srna`.`id`, `Srna`.`name`, `Srna`.`start`, `Srna`.`stop`, `Srna`.`strand`, `Srna`.`sequence_id`, `Srna`.`score`, `Srna`.`type_id`, `Srna`.`abundance`, `Srna`.`nomalized_abundance`, `Srna`.`experiment_id`, `Srna`.`chromosome_id`, `Sequence`.`id`, `Sequence`.`seq`, `Type`.`id`, `Type`.`name`, `Experiment`.`id`, `Experiment`.`name`, `Experiment`.`description`, `Experiment`.`species_id`, `Experiment`.`internal` FROM `srnas` AS `Srna` LEFT JOIN `sequences` AS `Sequence` ON (`Srna`.`sequence_id` = `Sequence`.`id`) LEFT JOIN `types` AS `Type` ON (`Srna`.`type_id` = `Type`.`id`) LEFT JOIN `experiments` AS `Experiment` ON (`Srna`.`experiment_id` = `Experiment`.`id`) WHERE chromosome_id = 7 LIMIT 500},
#            data => [],
#        },
#        'count range srnas' => {
#            q =>q{SELECT COUNT(*) AS `count` FROM `srnas` AS `Srna` WHERE `Srna`.`start` >= ? AND `Srna`.`stop` <= ? AND chromosome_id = 7 },
#            data => \@ranges,
#        },
#        'count all srnas' => {
#            q =>q{SELECT COUNT(*) AS `count` FROM `srnas` AS `Srna` WHERE chromosome_id = 7 },
#            data => [],
#        },
#    );
#
#
#    print "^ ", join "^", keys %qs;
#
#    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
#    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop_start` });
#    &exe('no index', \%qs);
#
#    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` ASC, `stop` ASC ) });
#    &exe('start_stop', \%qs);
#
#    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
#    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start` ( `start` ASC) });
#    &exe('start', \%qs);
#
#    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start` });
#    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop` ( `stop` ASC) });
#    &exe('stop', \%qs);
#
#    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop` });
#    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop_start` ( `stop` ASC, `start` ASC) });
#    &exe('stop_start', \%qs);
#
#    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop_start` });
#    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` DESC, `stop` DESC) });
#    &exe('start_stop DESC', \%qs);
#
#    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
#    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` ASC, `stop` DESC) });
#    &exe('start_stop ASC DESC', \%qs);
#
#    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
#    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` DESC, `stop` ASC) });
#    &exe('start_stop DESC ASC', \%qs);
#
#    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
#    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start` ( `start` DESC) });
#    &exe('start DESC', \%qs);
#
#    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start` });
#    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop` ( `stop` DESC) });
#    &exe('stop', \%qs);
#
#    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop` });
#    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop_start` ( `stop` DESC, `start` DESC) });
#    &exe('stop_start DESC DESC', \%qs);
#
#    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop_start` });
#    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop_start` ( `stop` ASC, `start` DESC) });
#    &exe('stop_start DESC ASC', \%qs);
#
#    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop_start` });
#    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop_start` ( `stop` DESC, `start` ASC) });
#    &exe('stop_start DESC ASC', \%qs);
#
#}

# test for the srnas with double indexes
{
    my @ids = (100..199);
    my @ranges = ();
    for my $i (1..100) {
        push @ranges, [ (3500 + $i*125), (4000 + $i*125) ] ;
    }

    my %qs = (
        'list one srna' => {
            q => q{  SELECT `Srna`.`id`, `Srna`.`name`, `Srna`.`start`, `Srna`.`stop`, `Srna`.`strand`, `Srna`.`sequence_id`, `Srna`.`score`, `Srna`.`type_id`, `Srna`.`abundance`, `Srna`.`nomalized_abundance`, `Srna`.`experiment_id`, `Srna`.`chromosome_id`, `Sequence`.`id`, `Sequence`.`seq`, `Type`.`id`, `Type`.`name`, `Experiment`.`id`, `Experiment`.`name`, `Experiment`.`description`, `Experiment`.`species_id`, `Experiment`.`internal` FROM `srnas` AS `Srna` LEFT JOIN `sequences` AS `Sequence` ON (`Srna`.`sequence_id` = `Sequence`.`id`) LEFT JOIN `types` AS `Type` ON (`Srna`.`type_id` = `Type`.`id`) LEFT JOIN `experiments` AS `Experiment` ON (`Srna`.`experiment_id` = `Experiment`.`id`) WHERE `Srna`.`id` =? },
            data => \@ids,
        },
        'list range srnas' => {
            q =>q{SELECT `Srna`.`id`, `Srna`.`name`, `Srna`.`start`, `Srna`.`stop`, `Srna`.`strand`, `Srna`.`sequence_id`, `Srna`.`score`, `Srna`.`type_id`, `Srna`.`abundance`, `Srna`.`nomalized_abundance`, `Srna`.`experiment_id`, `Srna`.`chromosome_id`, `Sequence`.`id`, `Sequence`.`seq`, `Type`.`id`, `Type`.`name`, `Experiment`.`id`, `Experiment`.`name`, `Experiment`.`description`, `Experiment`.`species_id`, `Experiment`.`internal` FROM `srnas` AS `Srna` LEFT JOIN `sequences` AS `Sequence` ON (`Srna`.`sequence_id` = `Sequence`.`id`) LEFT JOIN `types` AS `Type` ON (`Srna`.`type_id` = `Type`.`id`) LEFT JOIN `experiments` AS `Experiment` ON (`Srna`.`experiment_id` = `Experiment`.`id`) WHERE `Srna`.`start` >= ? AND `Srna`.`stop` <= ? AND chromosome_id = 7 },
            data => \@ranges,
        },
        'list all srnas' => {
            q => q{SELECT `Srna`.`id`, `Srna`.`name`, `Srna`.`start`, `Srna`.`stop`, `Srna`.`strand`, `Srna`.`sequence_id`, `Srna`.`score`, `Srna`.`type_id`, `Srna`.`abundance`, `Srna`.`nomalized_abundance`, `Srna`.`experiment_id`, `Srna`.`chromosome_id`, `Sequence`.`id`, `Sequence`.`seq`, `Type`.`id`, `Type`.`name`, `Experiment`.`id`, `Experiment`.`name`, `Experiment`.`description`, `Experiment`.`species_id`, `Experiment`.`internal` FROM `srnas` AS `Srna` LEFT JOIN `sequences` AS `Sequence` ON (`Srna`.`sequence_id` = `Sequence`.`id`) LEFT JOIN `types` AS `Type` ON (`Srna`.`type_id` = `Type`.`id`) LEFT JOIN `experiments` AS `Experiment` ON (`Srna`.`experiment_id` = `Experiment`.`id`) WHERE chromosome_id = 7 LIMIT 500},
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
    &exe('no index', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` ASC, `stop` ASC, `chromosome_id` ASC ) });
    &exe('start_stop', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start` ( `start` ASC, `chromosome_id` ASC) });
    &exe('start', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop` ( `stop` ASC, `chromosome_id` ASC) });
    &exe('stop', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop_start` ( `stop` ASC, `start` ASC, `chromosome_id` ASC) });
    &exe('stop_start', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop_start` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` DESC, `stop` DESC, `chromosome_id` ASC) });
    &exe('start_stop DESC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` ASC, `stop` DESC, `chromosome_id` ASC) });
    &exe('start_stop ASC DESC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start_stop` ( `start` DESC, `stop` ASC, `chromosome_id` ASC) });
    &exe('start_stop DESC ASC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start_stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `start` ( `start` DESC, `chromosome_id` ASC) });
    &exe('start DESC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `start` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop` ( `stop` DESC, `chromosome_id` ASC) });
    &exe('stop', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop_start` ( `stop` DESC, `start` DESC, `chromosome_id` ASC) });
    &exe('stop_start DESC DESC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop_start` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop_start` ( `stop` ASC, `start` DESC, `chromosome_id` ASC) });
    &exe('stop_start ASC DESC', \%qs);

    $dbi->do(q{ALTER TABLE `srnas` DROP INDEX `stop_start` });
    $dbi->do(q{ALTER TABLE `srnas` ADD INDEX `stop_start` ( `stop` DESC, `start` ASC, `chromosome_id` ASC) });
    &exe('stop_start DESC ASC', \%qs);

}

sub exe {
    my $title = shift;
    my $qs = shift;

    print "\n| $title |";
    while (my ($t, $exec) = each %$qs) {
        my $start = [gettimeofday()];
        my $sth = $dbi->prepare($exec->{ q });
        my $total = 1;
        if (@{ $exec->{ data } }) {
            foreach my $data (@{ $exec->{ data } }) {
                if (ref $data) {
                    $sth->execute( @$data );
                }
                else {
                    $sth->execute( $data );
                }
            }
            $total = scalar @{ $exec->{ data } };
        }
        else {
            $sth->execute();
        }
        my $stop = [gettimeofday()];

        printf " %.4f (%.4f) |", 1/tv_interval($start, $stop), tv_interval($start, $stop);
    }

    print "\n";
}

1;

__END__

=head1 SYNOPSIS

Test different indexing strategies on annotations and srnas
