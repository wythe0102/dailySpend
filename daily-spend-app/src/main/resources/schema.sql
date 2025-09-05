-- MySQL数据库初始化脚本
-- 基于用户提供的完整数据库结构

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 用户表
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `userId` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `username` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `password` varchar(400) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `sex` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `demo` varchar(20000) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `birthday` date DEFAULT NULL,
  `IdNum` varchar(40) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  PRIMARY KEY (`userId`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=4 CHARACTER SET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- 类型表
DROP TABLE IF EXISTS `type`;
CREATE TABLE `type` (
  `typeId` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(200) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `code` char(40) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `addDate` datetime DEFAULT NULL,
  `parentId` bigint DEFAULT NULL,
  `sequence` int DEFAULT 0,
  PRIMARY KEY (`typeId`) USING BTREE,
  INDEX `FK_Reference_2`(`parentId`) USING BTREE,
  CONSTRAINT `FK_Reference_2` FOREIGN KEY (`parentId`) REFERENCES `type` (`typeId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=55 CHARACTER SET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- 日常支出表
DROP TABLE IF EXISTS `daily_spend`;
CREATE TABLE `daily_spend` (
  `typeId` bigint DEFAULT NULL,
  `amount` decimal(18,2) DEFAULT NULL,
  `demo` varchar(20000) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `userId` bigint DEFAULT NULL,
  `date` date DEFAULT NULL,
  `spendDetailId` bigint NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`spendDetailId`) USING BTREE,
  INDEX `FK_Reference_1`(`typeId`) USING BTREE,
  INDEX `FK_Reference_3`(`userId`) USING BTREE,
  CONSTRAINT `FK_Reference_1` FOREIGN KEY (`typeId`) REFERENCES `type` (`typeId`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `FK_Reference_3` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=12499 CHARACTER SET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- 日常体重表
DROP TABLE IF EXISTS `daily_weight`;
CREATE TABLE `daily_weight` (
  `weightId` bigint NOT NULL AUTO_INCREMENT,
  `userId` bigint DEFAULT NULL,
  `weightAmount` double DEFAULT NULL,
  `time` datetime DEFAULT NULL,
  PRIMARY KEY (`weightId`) USING BTREE,
  INDEX `FK_Reference_5`(`userId`) USING BTREE,
  CONSTRAINT `FK_Reference_5` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=24 CHARACTER SET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- 预算表
DROP TABLE IF EXISTS `budget`;
CREATE TABLE `budget` (
  `budgetId` bigint NOT NULL AUTO_INCREMENT,
  `typeId` bigint DEFAULT NULL,
  `startDate` date DEFAULT NULL,
  `endDate` date DEFAULT NULL,
  `budgetAmount` decimal(18,2) DEFAULT NULL,
  `realAmount` decimal(18,2) DEFAULT NULL,
  `difference` decimal(18,2) DEFAULT NULL,
  `lastUpdate` datetime DEFAULT NULL,
  `realPercent` double DEFAULT NULL,
  `remarks` text CHARACTER SET utf8 COLLATE utf8_general_ci,
  PRIMARY KEY (`budgetId`) USING BTREE,
  INDEX `FK_Reference_4`(`typeId`) USING BTREE,
  CONSTRAINT `FK_Reference_4` FOREIGN KEY (`typeId`) REFERENCES `type` (`typeId`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=22 CHARACTER SET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

-- 成功日志表
DROP TABLE IF EXISTS `success_log`;
CREATE TABLE `success_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `content` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `date` datetime NOT NULL,
  `timeSpend` decimal(18,2) NOT NULL DEFAULT 0.00,
  `userId` bigint DEFAULT NULL,
  `sync` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=14 CHARACTER SET=utf8 COLLATE=utf8_general_ci ROW_FORMAT=DYNAMIC;

SET FOREIGN_KEY_CHECKS = 1;