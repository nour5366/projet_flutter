-- ========================================================
-- Base de données : scol_db
-- Pour XAMPP MySQL / MariaDB (Port standard: 3306)
-- TP7 & Suite TP7 - ISET Nabeul (DSI33 & DSI31)
-- ========================================================

CREATE DATABASE IF NOT EXISTS `scol_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `scol_db`;

-- 1. Table des utilisateurs (TP7)
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `user` (`id`, `email`, `password`) VALUES
(1, 'admin@gmail.com', 'admin'),
(2, 'foulen@gmail.com', 'foulen');

-- 2. Table Département (Suite TP7)
DROP TABLE IF EXISTS `departement`;
CREATE TABLE `departement` (
  `cod_dept` VARCHAR(20) PRIMARY KEY,
  `nom_dept` VARCHAR(150) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `departement` (`cod_dept`, `nom_dept`) VALUES
('TI', 'Technologies de l''Informatique'),
('GE', 'Génie Électrique'),
('GM', 'Génie Mécanique'),
('SEG', 'Sciences Économiques et Gestion');

-- 3. Table Classe (Suite TP7 & TP7)
DROP TABLE IF EXISTS `classe`;
CREATE TABLE `classe` (
  `cod_class` VARCHAR(20) PRIMARY KEY,
  `nom_class` VARCHAR(150) NOT NULL,
  `nbre_etud` INT DEFAULT 0,
  `cod_dept` VARCHAR(20),
  CONSTRAINT `fk_classe_dept` FOREIGN KEY (`cod_dept`) REFERENCES `departement`(`cod_dept`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `classe` (`cod_class`, `nom_class`, `nbre_etud`, `cod_dept`) VALUES
('DSI33', 'DSI 3.3', 25, 'TI'),
('DSI31', 'DSI 3.1', 28, 'TI'),
('DSI21', 'DSI 2.1', 30, 'TI'),
('DSI22', 'DSI 2.2', 29, 'TI'),
('DSI23', 'DSI 2.3', 27, 'TI'),
('RSI31', 'RSI 3.1', 24, 'TI'),
('SEM31', 'SEM 3.1', 22, 'GE');

-- 4. Table Etudiant (Suite TP7 & TP7)
DROP TABLE IF EXISTS `etudiant`;
CREATE TABLE `etudiant` (
  `nce` VARCHAR(20) PRIMARY KEY,
  `nom` VARCHAR(100) NOT NULL,
  `prenom` VARCHAR(100) NOT NULL,
  `date_nais` VARCHAR(20),
  `lieu_nais` VARCHAR(100),
  `cod_class` VARCHAR(20),
  CONSTRAINT `fk_etudiant_classe` FOREIGN KEY (`cod_class`) REFERENCES `classe`(`cod_class`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `etudiant` (`nce`, `nom`, `prenom`, `date_nais`, `lieu_nais`, `cod_class`) VALUES
('E1', 'Ben Foulen1', 'Foulen1', '2003-05-14', 'Nabeul', 'DSI33'),
('E2', 'Trabelsi', 'Ahmed', '2003-08-22', 'Tunis', 'DSI33'),
('E3', 'Gharbi', 'Sarra', '2004-01-10', 'Hammamet', 'DSI33'),
('E4', 'Mansour', 'Mohamed', '2003-11-03', 'Kelibia', 'DSI31');

-- 5. Table Matière (Suite TP7)
DROP TABLE IF EXISTS `matiere`;
CREATE TABLE `matiere` (
  `cod_mat` VARCHAR(20) PRIMARY KEY,
  `int_mat` VARCHAR(150) NOT NULL,
  `description` TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `matiere` (`cod_mat`, `int_mat`, `description`) VALUES
('AFCP', 'Atelier Framework Cross-Platform (Flutter)', 'Développement d''applications mobiles Flutter'),
('SOA', 'Architecture Orientée Services & Spring Boot', 'Microservices et Web Services REST'),
('BD', 'Bases de Données Avancées', 'Administration et optimisation SQL'),
('DEV', 'Génie Logiciel & DevOps', 'Méthodes agiles et déploiement continu');

-- 6. Table Absence (Suite TP7)
DROP TABLE IF EXISTS `absence`;
CREATE TABLE `absence` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `cod_mat` VARCHAR(20) NOT NULL,
  `nce` VARCHAR(20) NOT NULL,
  `date_a` VARCHAR(20) NOT NULL,
  `nha` DOUBLE NOT NULL DEFAULT 1.5,
  CONSTRAINT `fk_absence_matiere` FOREIGN KEY (`cod_mat`) REFERENCES `matiere`(`cod_mat`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_absence_etudiant` FOREIGN KEY (`nce`) REFERENCES `etudiant`(`nce`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Données initiales exactes du sujet de TP (Page 1 Suite TP7)
-- Pour l'étudiant E1 (Ben Foulen1 Foulen1) classe DSI33:
-- 11-11-2025 | AFCP | 1.5
-- 04-10-2025 | AFCP | 4.5 -> Total AFCP = 6.0
-- 20-10-2025 | SOA  | 1.5
-- 23-10-2025 | SOA  | 3.0
-- 16-10-2025 | SOA  | 3.0 -> Total SOA = 7.5
INSERT INTO `absence` (`cod_mat`, `nce`, `date_a`, `nha`) VALUES
('AFCP', 'E1', '11-11-2025', 1.5),
('AFCP', 'E1', '04-10-2025', 4.5),
('SOA', 'E1', '20-10-2025', 1.5),
('SOA', 'E1', '23-10-2025', 3.0),
('SOA', 'E1', '16-10-2025', 3.0),
('AFCP', 'E2', '15-10-2025', 3.0),
('SOA', 'E2', '18-10-2025', 1.5),
('AFCP', 'E1', '18-11-2025', 6.0),
('AFCP', 'E2', '18-11-2025', 3.0);

-- 7. Table ClassMat (Examen TP DSI32)
DROP TABLE IF EXISTS `class_mat`;
CREATE TABLE `class_mat` (
  `cod_mat` VARCHAR(20) NOT NULL,
  `cod_class` VARCHAR(20) NOT NULL,
  `coef` DOUBLE NOT NULL DEFAULT 1.5,
  `chsm` DOUBLE NOT NULL DEFAULT 45,
  PRIMARY KEY (`cod_mat`, `cod_class`),
  CONSTRAINT `fk_classmat_mat` FOREIGN KEY (`cod_mat`) REFERENCES `matiere`(`cod_mat`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_classmat_class` FOREIGN KEY (`cod_class`) REFERENCES `classe`(`cod_class`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `class_mat` (`cod_mat`, `cod_class`, `coef`, `chsm`) VALUES
('AFCP', 'DSI33', 1.5, 45),
('SOA', 'DSI33', 2.0, 42),
('BD', 'DSI33', 1.5, 21),
('DEV', 'DSI33', 1.5, 21),
('AFCP', 'DSI31', 1.5, 45),
('SOA', 'DSI31', 2.0, 42),
('BD', 'DSI31', 1.5, 21),
('DEV', 'DSI31', 1.5, 21);

-- 8. Table Formation (Optionnelle TP7)
DROP TABLE IF EXISTS `formation`;
CREATE TABLE `formation` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `nom` VARCHAR(100) NOT NULL,
  `duree` INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `formation` (`nom`, `duree`) VALUES
('Développement Mobile Flutter', 40),
('Backend Spring Boot & Microservices', 60);
