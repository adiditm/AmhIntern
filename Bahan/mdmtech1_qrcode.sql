-- Minimal MySQL schema for the xsystem bulk QR-code generator.
-- Reconstructed from manager/random.php and manager/index.php.

CREATE DATABASE IF NOT EXISTS `mdmtech1_qrcode`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `mdmtech1_qrcode`;

-- Supplies the country prefix dropdown used by manager/random.php.
CREATE TABLE IF NOT EXISTS `m_country` (
  `fcountry_code` CHAR(2) NOT NULL,
  `fcountry_name` VARCHAR(100) NOT NULL,
  PRIMARY KEY (`fcountry_code`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Default prefix required for Indonesian QR serial generation.
INSERT INTO `m_country` (`fcountry_code`, `fcountry_name`)
VALUES ('ID', 'Indonesia')
ON DUPLICATE KEY UPDATE `fcountry_name` = VALUES(`fcountry_name`);

-- Stores each generated serial.
-- Existing generator format: 2-char country code + 10 letters + 10 digits.
CREATE TABLE IF NOT EXISTS `tb_sernum` (
  `fsernum` VARCHAR(22) NOT NULL,
  `ftime` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fstatus` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`fsernum`),
  KEY `idx_tb_sernum_status` (`fstatus`),
  KEY `idx_tb_sernum_time` (`ftime`),
  CONSTRAINT `chk_tb_sernum_length` CHECK (CHAR_LENGTH(`fsernum`) = 22),
  CONSTRAINT `chk_tb_sernum_status` CHECK (`fstatus` IN (0, 1))
) ENGINE=InnoDB DEFAULT CHARACTER SET ascii COLLATE=ascii_bin;
