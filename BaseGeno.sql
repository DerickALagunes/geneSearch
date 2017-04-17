-- MySQL Script generated by MySQL Workbench
-- 04/15/17 20:05:26
-- Model: New Model    Version: 1.0
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8 ;
USE `mydb` ;

-- -----------------------------------------------------
-- Table `mydb`.`DataBank`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`DataBank` (
  `idDataBank` VARCHAR(45) NOT NULL,
  `name` VARCHAR(45) NULL,
  `description` VARCHAR(45) NULL,
  PRIMARY KEY (`idDataBank`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Gene`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Gene` (
  `idSymbol` VARCHAR(45) NOT NULL,
  `idHugo` VARCHAR(45) NULL,
  `officialName` VARCHAR(45) NULL,
  `summary` VARCHAR(45) NULL,
  `chromosome` VARCHAR(45) NULL,
  `locus` VARCHAR(45) NULL,
  PRIMARY KEY (`idSymbol`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`allele`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`allele` (
  `ordnum` INT NOT NULL,
  `start_position` MEDIUMTEXT NULL,
  `end_position` MEDIUMTEXT NULL,
  `strand` VARCHAR(45) NULL,
  PRIMARY KEY (`ordnum`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`Gene_has_DataBank`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`Gene_has_DataBank` (
  `idGene` VARCHAR(45) NOT NULL,
  `idDataBank` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`idGene`, `idDataBank`),
  INDEX `fk_Gene_has_DataBank_DataBank1_idx` (`idDataBank` ASC),
  INDEX `fk_Gene_has_DataBank_Gene_idx` (`idGene` ASC),
  CONSTRAINT `fk_Gene_has_DataBank_Gene`
    FOREIGN KEY (`idGene`)
    REFERENCES `mydb`.`Gene` (`idSymbol`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_Gene_has_DataBank_DataBank1`
    FOREIGN KEY (`idDataBank`)
    REFERENCES `mydb`.`DataBank` (`idDataBank`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`DataBank_has_allele`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`DataBank_has_allele` (
  `allele_ordnum` INT NOT NULL,
  `DataBank_idDataBank` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`allele_ordnum`, `DataBank_idDataBank`),
  INDEX `fk_DataBank_has_allele_allele1_idx` (`allele_ordnum` ASC),
  INDEX `fk_DataBank_has_allele_DataBank1_idx` (`DataBank_idDataBank` ASC),
  CONSTRAINT `fk_DataBank_has_allele_allele1`
    FOREIGN KEY (`allele_ordnum`)
    REFERENCES `mydb`.`allele` (`ordnum`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_DataBank_has_allele_DataBank1`
    FOREIGN KEY (`DataBank_idDataBank`)
    REFERENCES `mydb`.`DataBank` (`idDataBank`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`AllelicReferenceType`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`AllelicReferenceType` (
  `sequense` VARCHAR(45) NOT NULL,
  `Gene_idSymbol` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`sequense`, `Gene_idSymbol`),
  INDEX `fk_AllelicReferenceType_Gene1_idx` (`Gene_idSymbol` ASC),
  CONSTRAINT `fk_AllelicReferenceType_Gene1`
    FOREIGN KEY (`Gene_idSymbol`)
    REFERENCES `mydb`.`Gene` (`idSymbol`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`GeneDataBankIdentificacion`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`GeneDataBankIdentificacion` (
  `DataBank_idDataBank` VARCHAR(45) NOT NULL,
  `Gene_idSymbol` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`DataBank_idDataBank`, `Gene_idSymbol`),
  INDEX `fk_GeneDataBankIdentificacion_DataBank1_idx` (`DataBank_idDataBank` ASC),
  INDEX `fk_GeneDataBankIdentificacion_Gene1_idx` (`Gene_idSymbol` ASC),
  CONSTRAINT `fk_GeneDataBankIdentificacion_DataBank1`
    FOREIGN KEY (`DataBank_idDataBank`)
    REFERENCES `mydb`.`DataBank` (`idDataBank`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_GeneDataBankIdentificacion_Gene1`
    FOREIGN KEY (`Gene_idSymbol`)
    REFERENCES `mydb`.`Gene` (`idSymbol`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`AlleleDataBankIndentificacion`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`AlleleDataBankIndentificacion` (
  `DataBank_idDataBank` VARCHAR(45) NOT NULL,
  `allele_ordnum` INT NOT NULL,
  PRIMARY KEY (`DataBank_idDataBank`, `allele_ordnum`),
  INDEX `fk_DataBank_has_allele1_allele1_idx` (`allele_ordnum` ASC),
  INDEX `fk_DataBank_has_allele1_DataBank1_idx` (`DataBank_idDataBank` ASC),
  CONSTRAINT `fk_DataBank_has_allele1_DataBank1`
    FOREIGN KEY (`DataBank_idDataBank`)
    REFERENCES `mydb`.`DataBank` (`idDataBank`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_DataBank_has_allele1_allele1`
    FOREIGN KEY (`allele_ordnum`)
    REFERENCES `mydb`.`allele` (`ordnum`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`BiblliographyDB`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`BiblliographyDB` (
  `BiblliographyNameDB` INT NOT NULL,
  `URL` VARCHAR(45) NULL,
  PRIMARY KEY (`BiblliographyNameDB`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `mydb`.`BibliographyReference`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`BibliographyReference` (
  `id` INT NOT NULL,
  `title` VARCHAR(45) NULL,
  `authors` VARCHAR(45) NULL,
  `abstract` VARCHAR(45) NULL,
  `publication` VARCHAR(45) NULL,
  `BiblliographyDB_BiblliographyNameDB` INT NOT NULL,
  `Gene_idSymbol` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`, `BiblliographyDB_BiblliographyNameDB`, `Gene_idSymbol`),
  INDEX `fk_BibliographyReference_BiblliographyDB1_idx` (`BiblliographyDB_BiblliographyNameDB` ASC),
  INDEX `fk_BibliographyReference_Gene1_idx` (`Gene_idSymbol` ASC),
  CONSTRAINT `fk_BibliographyReference_BiblliographyDB1`
    FOREIGN KEY (`BiblliographyDB_BiblliographyNameDB`)
    REFERENCES `mydb`.`BiblliographyDB` (`BiblliographyNameDB`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_BibliographyReference_Gene1`
    FOREIGN KEY (`Gene_idSymbol`)
    REFERENCES `mydb`.`Gene` (`idSymbol`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

USE `mydb` ;

-- -----------------------------------------------------
-- Placeholder table for view `mydb`.`view1`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `mydb`.`view1` (`id` INT);

-- -----------------------------------------------------
-- View `mydb`.`view1`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `mydb`.`view1`;
USE `mydb`;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
