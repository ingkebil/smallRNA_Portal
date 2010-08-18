-- MySQL dump 10.13  Distrib 5.1.47, for unknown-linux-gnu (x86_64)
--
-- Host: localhost    Database: smallrna_opt
-- ------------------------------------------------------
-- Server version	5.1.47

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `annotations`
--

DROP TABLE IF EXISTS `annotations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `annotations` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `accession_nr` varchar(45) NOT NULL,
  `model_nr` tinyint(3) unsigned NOT NULL,
  `start` int(10) unsigned NOT NULL,
  `stop` int(10) unsigned NOT NULL,
  `strand` enum('+','-') NOT NULL,
  `chromosome_id` mediumint(8) unsigned NOT NULL,
  `type` enum('transposable_element','mRNA_TE_gene','mRNA','snRNA','rRNA','snoRNA','miRNA','tRNA','ncRNA','pseudogenic_transcript') DEFAULT NULL,
  `species_id` smallint(5) unsigned NOT NULL,
  `seq` text NOT NULL,
  `comment` text NOT NULL,
  `source_id` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_annotations_sources1` (`source_id`),
  KEY `start_stop` (`start`,`chromosome_id`,`species_id`,`stop`),
  KEY `accession_model` (`accession_nr`,`model_nr`),
  KEY `fk_annotations_species1` (`species_id`),
  KEY `fk_annotations_chromosomes1` (`chromosome_id`),
  CONSTRAINT `fk_annotations_chromosomes1` FOREIGN KEY (`chromosome_id`) REFERENCES `chromosomes` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_annotations_sources1` FOREIGN KEY (`source_id`) REFERENCES `sources` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_annotations_species1` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=70830 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `chromosomes`
--

DROP TABLE IF EXISTS `chromosomes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chromosomes` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `length` int(10) unsigned NOT NULL,
  `species_id` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_chromosomes_species1` (`species_id`),
  CONSTRAINT `fk_chromosomes_species1` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `experiments`
--

DROP TABLE IF EXISTS `experiments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `experiments` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `description` text,
  `species_id` smallint(5) unsigned NOT NULL,
  `internal` smallint(5) unsigned DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `fk_experiments_species1` (`species_id`),
  CONSTRAINT `fk_experiments_species1` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mappings`
--

DROP TABLE IF EXISTS `mappings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mappings` (
  `annotation_id` int(11) unsigned NOT NULL,
  `srna_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`annotation_id`,`srna_id`),
  KEY `fk_mappings_srnas1` (`srna_id`),
  KEY `fk_mappings_annotations1` (`annotation_id`),
  CONSTRAINT `fk_mappings_annotations1` FOREIGN KEY (`annotation_id`) REFERENCES `annotations` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_mappings_srnas1` FOREIGN KEY (`srna_id`) REFERENCES `srnas` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mismatches`
--

DROP TABLE IF EXISTS `mismatches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mismatches` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `srna_id` int(10) unsigned NOT NULL,
  `pos` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_mismatches_srnas1` (`srna_id`),
  CONSTRAINT `fk_mismatches_srnas1` FOREIGN KEY (`srna_id`) REFERENCES `srnas` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sequences`
--

DROP TABLE IF EXISTS `sequences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sequences` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `seq` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `seq` (`seq`)
) ENGINE=InnoDB AUTO_INCREMENT=10449486 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sources`
--

DROP TABLE IF EXISTS `sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sources` (
  `id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `description` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `species`
--

DROP TABLE IF EXISTS `species`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `species` (
  `id` smallint(5) unsigned NOT NULL,
  `full_name` varchar(45) NOT NULL,
  `short_name` varchar(5) NOT NULL COMMENT 'Short 5 letter name for the species',
  `NCBI_tax_id` mediumint(8) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `short_name_un` (`short_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `srnas`
--

DROP TABLE IF EXISTS `srnas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `srnas` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `start` int(10) unsigned NOT NULL,
  `stop` int(10) unsigned NOT NULL,
  `strand` enum('+','-') NOT NULL,
  `sequence_id` int(11) unsigned NOT NULL,
  `score` float NOT NULL,
  `type_id` smallint(5) unsigned NOT NULL,
  `abundance` mediumint(8) unsigned NOT NULL,
  `normalized_abundance` float NOT NULL,
  `experiment_id` smallint(5) unsigned NOT NULL,
  `chromosome_id` mediumint(8) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `start_stop` (`start`,`stop`,`type_id`,`experiment_id`),
  KEY `fk_snras_Sequences1` (`sequence_id`),
  KEY `fk_snras_experiments1` (`experiment_id`),
  KEY `fk_snras_types1` (`type_id`),
  KEY `fk_srnas_chromosomes1` (`chromosome_id`),
  CONSTRAINT `fk_snras_experiments1` FOREIGN KEY (`experiment_id`) REFERENCES `experiments` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_snras_Sequences1` FOREIGN KEY (`sequence_id`) REFERENCES `sequences` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_snras_types1` FOREIGN KEY (`type_id`) REFERENCES `types` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_srnas_chromosomes1` FOREIGN KEY (`chromosome_id`) REFERENCES `chromosomes` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=24158139 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `structures`
--

DROP TABLE IF EXISTS `structures`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `structures` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `annotation_id` int(11) unsigned NOT NULL,
  `start` int(10) unsigned NOT NULL,
  `stop` int(10) unsigned NOT NULL,
  `utr` enum('Y','N') NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_structures_annotations1` (`annotation_id`),
  CONSTRAINT `fk_structures_annotations1` FOREIGN KEY (`annotation_id`) REFERENCES `annotations` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=283551 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `types`
--

DROP TABLE IF EXISTS `types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `types` (
  `id` smallint(5) unsigned NOT NULL,
  `name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2010-08-18  9:59:48
