-- phpMyAdmin SQL Dump
-- version 3.3.4
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Jul 21, 2010 at 04:45 PM
-- Server version: 5.1.47
-- PHP Version: 5.3.2

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Database: `smallrna`
--

-- --------------------------------------------------------

--
-- Table structure for table `annotations`
--

CREATE TABLE `annotations` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `accession_nr` varchar(45) NOT NULL,
      `model_nr` int(11) NOT NULL,
      `start` int(11) NOT NULL,
      `stop` int(11) NOT NULL,
      `strand` enum('+','-') NOT NULL,
      `chromosome_id` int(11) NOT NULL,
      `type` enum('transposable_element','mRNA_TE_gene','mRNA','snRNA','rRNA','snoRNA','miRNA','tRNA','ncRNA','pseudogenic_transcript') DEFAULT NULL,
      `species_id` int(11) NOT NULL,
      `seq` text NOT NULL,
      `comment` text NOT NULL,
      `source_id` int(11) NOT NULL,
      PRIMARY KEY (`id`),
      KEY `fk_annotations_sources1` (`source_id`),
      KEY `start_stop` (`start`,`chromosome_id`,`species_id`,`stop`),
      KEY `accession_model` (`accession_nr`,`model_nr`),
      KEY `fk_annotations_species1` (`species_id`),
      KEY `fk_annotations_chromosomes1` (`chromosome_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `chromosomes`
--

CREATE TABLE `chromosomes` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `name` varchar(45) NOT NULL,
      `length` int(11) NOT NULL,
      `species_id` int(11) NOT NULL,
      PRIMARY KEY (`id`),
      KEY `fk_chromosomes_species1` (`species_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `experiments`
--

CREATE TABLE `experiments` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `name` varchar(45) NOT NULL,
      `description` text,
      `species_id` int(11) NOT NULL,
      `internal` smallint(6) DEFAULT '0',
      PRIMARY KEY (`id`),
      KEY `fk_experiments_species1` (`species_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `sequences`
--

CREATE TABLE `sequences` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `seq` varchar(45) NOT NULL,
      PRIMARY KEY (`id`),
      UNIQUE KEY `seq` (`seq`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `sources`
--

CREATE TABLE `sources` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `name` varchar(45) NOT NULL,
      `description` text NOT NULL,
      PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `species`
--

CREATE TABLE `species` (
      `id` int(11) NOT NULL,
      `full_name` varchar(45) NOT NULL,
      `short_name` varchar(5) NOT NULL COMMENT 'Short 5 letter name for the species',
      `NCBI_tax_id` int(11) NOT NULL,
      PRIMARY KEY (`id`),
      UNIQUE KEY `short_name_un` (`short_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `srnas`
--

CREATE TABLE `srnas` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `name` varchar(45) NOT NULL,
      `start` int(11) NOT NULL,
      `stop` int(11) NOT NULL,
      `strand` enum('+','-') NOT NULL,
      `sequence_id` int(11) NOT NULL,
      `score` float NOT NULL,
      `type_id` int(11) NOT NULL,
      `abundance` int(11) NOT NULL,
      `nomalized_abundance` float NOT NULL,
      `experiment_id` int(11) NOT NULL,
      PRIMARY KEY (`id`),
      KEY `start_stop` (`start`,`stop`,`type_id`,`experiment_id`),
      KEY `fk_snras_Sequences1` (`sequence_id`),
      KEY `fk_snras_experiments1` (`experiment_id`),
      KEY `fk_snras_types1` (`type_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `structures`
--

CREATE TABLE `structures` (
      `id` int(11) NOT NULL AUTO_INCREMENT,
      `annotation_id` int(11) NOT NULL,
      `start` int(11) NOT NULL,
      `stop` int(11) NOT NULL,
      `utr` enum('Y','N') NOT NULL,
      PRIMARY KEY (`id`),
      KEY `fk_structures_annotations1` (`annotation_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `types`
--

CREATE TABLE `types` (
      `id` int(11) NOT NULL,
      `name` varchar(45) NOT NULL,
      PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `annotations`
--
ALTER TABLE `annotations`
  ADD CONSTRAINT `fk_annotations_chromosomes1` FOREIGN KEY (`chromosome_id`) REFERENCES `chromosomes` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_annotations_sources1` FOREIGN KEY (`source_id`) REFERENCES `sources` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_annotations_species1` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `chromosomes`
--
ALTER TABLE `chromosomes`
  ADD CONSTRAINT `fk_chromosomes_species1` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `experiments`
--
ALTER TABLE `experiments`
  ADD CONSTRAINT `fk_experiments_species1` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `srnas`
--
ALTER TABLE `srnas`
  ADD CONSTRAINT `fk_snras_experiments1` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_snras_Sequences1` FOREIGN KEY (`sequence_id`) REFERENCES `sequences` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_snras_types1` FOREIGN KEY (`type_id`) REFERENCES `types` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Constraints for table `structures`
--
ALTER TABLE `structures`
  ADD CONSTRAINT `fk_structures_annotations1` FOREIGN KEY (`annotation_id`) REFERENCES `annotations` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

