SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `smallrna` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;

-- -----------------------------------------------------
-- Table `smallrna`.`sources`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `smallrna`.`sources` ;

CREATE  TABLE IF NOT EXISTS `smallrna`.`sources` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) NOT NULL ,
  `description` TEXT NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `smallrna`.`species`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `smallrna`.`species` ;

CREATE  TABLE IF NOT EXISTS `smallrna`.`species` (
  `id` INT NOT NULL ,
  `full_name` VARCHAR(45) NOT NULL ,
  `NCBI_tax_id` INT NOT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `smallrna`.`annotations`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `smallrna`.`annotations` ;

CREATE  TABLE IF NOT EXISTS `smallrna`.`annotations` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `accession_nr` VARCHAR(45) NOT NULL ,
  `model_nr` INT NOT NULL ,
  `start` INT NOT NULL ,
  `stop` INT NOT NULL ,
  `strand` ENUM('+','-') NOT NULL ,
  `chr` VARCHAR(45) NOT NULL ,
  `type` ENUM('coding gene', 'cDNA', 'rRNA', 'snoRNA', 'ncRNA', 'tRNA', 'miRNA', 'snRNA', 'TE', 'pseudogene') NOT NULL ,
  `species_id` INT NOT NULL ,
  `seq` TEXT NOT NULL ,
  `comment` TEXT NOT NULL ,
  `source_id` INT NOT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_annotations_sources1`
    FOREIGN KEY (`source_id` )
    REFERENCES `smallrna`.`sources` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_annotations_species1`
    FOREIGN KEY (`species_id` )
    REFERENCES `smallrna`.`species` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_annotations_sources1` ON `smallrna`.`annotations` (`source_id` ASC) ;

CREATE INDEX `start_stop` ON `smallrna`.`annotations` (`start` ASC, `chr` ASC, `species_id` ASC, `stop` ASC) ;

CREATE INDEX `accession_model` ON `smallrna`.`annotations` (`accession_nr` ASC, `model_nr` ASC) ;

CREATE INDEX `fk_annotations_species1` ON `smallrna`.`annotations` (`species_id` ASC) ;


-- -----------------------------------------------------
-- Table `smallrna`.`structures`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `smallrna`.`structures` ;

CREATE  TABLE IF NOT EXISTS `smallrna`.`structures` (
  `id` INT NOT NULL ,
  `annotation_id` INT NOT NULL ,
  `start` INT NOT NULL ,
  `stop` INT NOT NULL ,
  `utr` ENUM('Y','N') NOT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_structures_annotations1`
    FOREIGN KEY (`annotation_id` )
    REFERENCES `smallrna`.`annotations` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_structures_annotations1` ON `smallrna`.`structures` (`annotation_id` ASC) ;


-- -----------------------------------------------------
-- Table `smallrna`.`sequences`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `smallrna`.`sequences` ;

CREATE  TABLE IF NOT EXISTS `smallrna`.`sequences` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `seq` VARCHAR(45) NULL ,
  `seq_hash` INT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;

CREATE INDEX `seq_hash` ON `smallrna`.`sequences` (`seq_hash` ASC) ;


-- -----------------------------------------------------
-- Table `smallrna`.`experiments`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `smallrna`.`experiments` ;

CREATE  TABLE IF NOT EXISTS `smallrna`.`experiments` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) NULL ,
  `description` TEXT NULL ,
  `species_id` INT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_experiments_species1`
    FOREIGN KEY (`species_id` )
    REFERENCES `smallrna`.`species` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_experiments_species1` ON `smallrna`.`experiments` (`species_id` ASC) ;


-- -----------------------------------------------------
-- Table `smallrna`.`types`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `smallrna`.`types` ;

CREATE  TABLE IF NOT EXISTS `smallrna`.`types` (
  `id` INT NOT NULL ,
  `name` VARCHAR(45) NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `smallrna`.`snras`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `smallrna`.`snras` ;

CREATE  TABLE IF NOT EXISTS `smallrna`.`snras` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) NOT NULL ,
  `start` INT NOT NULL ,
  `stop` INT NOT NULL ,
  `strand` ENUM('+','-') NOT NULL ,
  `sequence_id` INT NOT NULL ,
  `score` FLOAT NOT NULL ,
  `type_id` INT NOT NULL ,
  `abundance` INT NOT NULL ,
  `nomalized_abundance` FLOAT NOT NULL ,
  `experiment_id` INT NOT NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_snras_Sequences1`
    FOREIGN KEY (`sequence_id` )
    REFERENCES `smallrna`.`sequences` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_snras_experiments1`
    FOREIGN KEY (`experiment_id` )
    REFERENCES `smallrna`.`experiments` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_snras_types1`
    FOREIGN KEY (`type_id` )
    REFERENCES `smallrna`.`types` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `start_stop` ON `smallrna`.`snras` (`start` ASC, `stop` ASC, `type_id` ASC, `experiment_id` ASC) ;

CREATE INDEX `fk_snras_Sequences1` ON `smallrna`.`snras` (`sequence_id` ASC) ;

CREATE INDEX `fk_snras_experiments1` ON `smallrna`.`snras` (`experiment_id` ASC) ;

CREATE INDEX `fk_snras_types1` ON `smallrna`.`snras` (`type_id` ASC) ;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
