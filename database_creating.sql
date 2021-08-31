-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema store_db
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema store_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `store_db` DEFAULT CHARACTER SET utf8 ;
USE `store_db` ;

-- -----------------------------------------------------
-- Table `store_db`.`customers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `store_db`.`customers` (
  `customer_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `first_name` VARCHAR(45) NOT NULL,
  `last_name` VARCHAR(45) NOT NULL,
  `birth_date` DATE NULL,
  `phone` VARCHAR(45) NULL,
  `state` CHAR(2) NOT NULL,
  `city` VARCHAR(45) NOT NULL,
  `points` VARCHAR(45) NOT NULL DEFAULT 0,
  PRIMARY KEY (`customer_id`),
  UNIQUE INDEX `customer_id_UNIQUE` (`customer_id` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `store_db`.`orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `store_db`.`orders` (
  `order_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` INT UNSIGNED NOT NULL,
  `amound_due` FLOAT UNSIGNED NOT NULL,
  `amount_paid` FLOAT UNSIGNED NOT NULL DEFAULT 0,
  `order_date` DATE NOT NULL,
  PRIMARY KEY (`order_id`),
  UNIQUE INDEX `order_id_UNIQUE` (`order_id` ASC) VISIBLE,
  INDEX `fk_orders_customers_idx` (`customer_id` ASC) VISIBLE,
  CONSTRAINT `fk_orders_customers`
    FOREIGN KEY (`customer_id`)
    REFERENCES `store_db`.`customers` (`customer_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `store_db`.`products`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `store_db`.`products` (
  `product_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `price` FLOAT UNSIGNED NOT NULL,
  `product_name` VARCHAR(45) NOT NULL,
  `num_in_stock` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`product_id`),
  UNIQUE INDEX `product_id_UNIQUE` (`product_id` ASC) VISIBLE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `store_db`.`order_detail`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `store_db`.`order_detail` (
  `order_id` INT UNSIGNED NOT NULL,
  `product_id` INT UNSIGNED NOT NULL,
  `quantity` INT UNSIGNED NOT NULL,
  `notes` VARCHAR(255) NULL,
  INDEX `fk_order_detail_orders1_idx` (`order_id` ASC) VISIBLE,
  INDEX `fk_order_detail_products1_idx` (`product_id` ASC) VISIBLE,
  PRIMARY KEY (`order_id`, `product_id`),
  CONSTRAINT `fk_order_detail_orders1`
    FOREIGN KEY (`order_id`)
    REFERENCES `store_db`.`orders` (`order_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_order_detail_products1`
    FOREIGN KEY (`product_id`)
    REFERENCES `store_db`.`products` (`product_id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `store_db`.`payments`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `store_db`.`payments` (
  `payment_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `order_id` INT UNSIGNED NOT NULL,
  `customer_id` INT UNSIGNED NOT NULL,
  `amount` FLOAT UNSIGNED NOT NULL,
  `payment_date` DATE NOT NULL,
  INDEX `fk_payments_orders1_idx` (`order_id` ASC) VISIBLE,
  PRIMARY KEY (`payment_id`),
  UNIQUE INDEX `payment_id_UNIQUE` (`payment_id` ASC) VISIBLE,
  INDEX `fk_payments_customers1_idx` (`customer_id` ASC) VISIBLE,
  CONSTRAINT `fk_payments_orders1`
    FOREIGN KEY (`order_id`)
    REFERENCES `store_db`.`orders` (`order_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT `fk_payments_customers1`
    FOREIGN KEY (`customer_id`)
    REFERENCES `store_db`.`customers` (`customer_id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
