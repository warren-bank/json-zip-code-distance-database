CREATE DATABASE IF NOT EXISTS `zipcode_spatial_relations`;

USE `zipcode_spatial_relations`;

-- cleanup
-- -------------------------------------------------------------------

DROP TABLE IF EXISTS `zipcode_spatial`;
DROP TABLE IF EXISTS `zipcode_mapping`;

-- initialize
-- -------------------------------------------------------------------

CREATE TABLE `zipcode_spatial` (
  `id`           int(10) unsigned NOT NULL AUTO_INCREMENT,
  `zipcode`      char(5)          NOT NULL,
  `longitude`    decimal(5,2)     NOT NULL,
  `latitude`     decimal(5,2)     NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM;

CREATE TABLE `zipcode_mapping` (
  `focal_id`     int(10)      unsigned NOT NULL,
  `proximate_id` int(10)      unsigned NOT NULL,
  `distance`     decimal(4,1) unsigned NOT NULL,
  PRIMARY KEY (`focal_id`, `proximate_id`),
  KEY (`focal_id`)
) ENGINE=MyISAM;
