SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `cc500201_db` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci ;
USE `cc500201_db` ;

-- -----------------------------------------------------
-- Table `cc500201_db`.`espacio`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cc500201_db`.`espacio` (
  `id` INT NOT NULL,
  `valor` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `cc500201_db`.`region`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cc500201_db`.`region` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(200) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `cc500201_db`.`comuna`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cc500201_db`.`comuna` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nombre` VARCHAR(200) NOT NULL,
  `region_id` INT NOT NULL,
  PRIMARY KEY (`id`, `region_id`),
  INDEX `fk_comuna_region1_idx` (`region_id` ASC),
  CONSTRAINT `fk_comuna_region1`
    FOREIGN KEY (`region_id`)
    REFERENCES `cc500201_db`.`region` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `cc500201_db`.`voluntario`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cc500201_db`.`voluntario` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `nombre_voluntario` VARCHAR(80) NOT NULL,
  `email_voluntario` VARCHAR(30) NOT NULL,
  `celular_voluntario` VARCHAR(15) NULL,
  `espacio_disponible` INT NOT NULL,
  `comuna_disponible` INT NOT NULL,
  `descripcion` VARCHAR(500) NULL,
  PRIMARY KEY (`id`),
  INDEX `espacio_fk_idx` (`espacio_disponible` ASC),
  INDEX `fk_viaje_comuna1_idx` (`comuna_disponible` ASC),
  CONSTRAINT `espacio_fk`
    FOREIGN KEY (`espacio_disponible`)
    REFERENCES `cc500201_db`.`espacio` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_viaje_comuna1`
    FOREIGN KEY (`comuna_disponible`)
    REFERENCES `cc500201_db`.`comuna` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `cc500201_db`.`tipo_mascota`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cc500201_db`.`tipo_mascota` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `descripcion` VARCHAR(45) NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `cc500201_db`.`traslado`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cc500201_db`.`traslado` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `comuna_origen` INT NOT NULL,
  `comuna_destino` INT NOT NULL,
  `fecha_viaje` DATETIME NOT NULL,
  `espacio` INT NOT NULL,
  `tipo_mascota_id` INT NOT NULL,
  `descripcion` VARCHAR(500) NULL,
  `nombre_contacto` VARCHAR(80) NOT NULL,
  `email_contacto` VARCHAR(30) NOT NULL,
  `celular_contacto` VARCHAR(15) NULL,
  PRIMARY KEY (`id`),
  INDEX `espacio_e_fk_idx` (`espacio` ASC),
  INDEX `fk_encargo_comuna1_idx` (`comuna_origen` ASC),
  INDEX `fk_encargo_comuna2_idx` (`comuna_destino` ASC),
  INDEX `fk_traslado_tipo_mascota1_idx` (`tipo_mascota_id` ASC),
  CONSTRAINT `espacio_e_fk`
    FOREIGN KEY (`espacio`)
    REFERENCES `cc500201_db`.`espacio` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_encargo_comuna1`
    FOREIGN KEY (`comuna_origen`)
    REFERENCES `cc500201_db`.`comuna` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_encargo_comuna2`
    FOREIGN KEY (`comuna_destino`)
    REFERENCES `cc500201_db`.`comuna` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_traslado_tipo_mascota1`
    FOREIGN KEY (`tipo_mascota_id`)
    REFERENCES `cc500201_db`.`tipo_mascota` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `cc500201_db`.`foto_mascota`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `cc500201_db`.`foto_mascota` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `ruta_archivo` VARCHAR(300) NOT NULL,
  `nombre_archivo` VARCHAR(300) NULL,
  `traslado_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_foto_mascota_traslado1_idx` (`traslado_id` ASC),
  CONSTRAINT `fk_foto_mascota_traslado1`
    FOREIGN KEY (`traslado_id`)
    REFERENCES `cc500201_db`.`traslado` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `cc500201_db`.`espacio`
-- -----------------------------------------------------
START TRANSACTION;
USE `cc500201_db`;
INSERT INTO `cc500201_db`.`espacio` (`id`, `valor`) VALUES (1, '10x10x10');
INSERT INTO `cc500201_db`.`espacio` (`id`, `valor`) VALUES (2, '20x20x20');
INSERT INTO `cc500201_db`.`espacio` (`id`, `valor`) VALUES (3, '30x30x30');

INSERT INTO `cc500201_db`.`tipo_mascota` (`descripcion`) VALUES ('perro');
INSERT INTO `cc500201_db`.`tipo_mascota` (`descripcion`) VALUES ('gato');
INSERT INTO `cc500201_db`.`tipo_mascota` (`descripcion`) VALUES ('hámster');
INSERT INTO `cc500201_db`.`tipo_mascota` (`descripcion`) VALUES ('conejo');
INSERT INTO `cc500201_db`.`tipo_mascota` (`descripcion`) VALUES ('tortuga');
COMMIT;

