CREATE TABLE IF NOT EXISTS `cloakrooms` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    `coords` JSON NOT NULL,
    PRIMARY KEY (`id`)
);
