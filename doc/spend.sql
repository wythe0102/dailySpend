/*
Navicat MySQL Data Transfer

Source Server         : mysql
Source Server Version : 50626
Source Host           : localhost:3306
Source Database       : spend

Target Server Type    : MYSQL
Target Server Version : 50626
File Encoding         : 65001

Date: 2015-08-11 22:05:02
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for budget
-- ----------------------------
DROP TABLE IF EXISTS `budget`;
CREATE TABLE `budget` (
  `budgetId` bigint(20) NOT NULL AUTO_INCREMENT,
  `typeId` bigint(20) DEFAULT NULL,
  `startDate` date DEFAULT NULL,
  `endDate` date DEFAULT NULL,
  `budgetAmount` decimal(18,2) DEFAULT NULL,
  `realAmount` decimal(18,2) DEFAULT NULL,
  `difference` decimal(18,2) DEFAULT NULL,
  `lastUpdate` datetime DEFAULT NULL,
  `realPercent` double DEFAULT NULL,
  `remarks` text,
  PRIMARY KEY (`budgetId`),
  KEY `FK_Reference_4` (`typeId`),
  CONSTRAINT `FK_Reference_4` FOREIGN KEY (`typeId`) REFERENCES `type` (`typeId`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for daily_spend
-- ----------------------------
DROP TABLE IF EXISTS `daily_spend`;
CREATE TABLE `daily_spend` (
  `typeId` bigint(20) DEFAULT NULL,
  `amount` decimal(18,2) DEFAULT NULL,
  `demo` varchar(20000) DEFAULT NULL,
  `userId` bigint(20) DEFAULT NULL,
  `date` date DEFAULT NULL,
  `spendDetailId` bigint(20) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`spendDetailId`),
  KEY `FK_Reference_1` (`typeId`),
  KEY `FK_Reference_3` (`userId`),
  CONSTRAINT `FK_Reference_1` FOREIGN KEY (`typeId`) REFERENCES `type` (`typeId`),
  CONSTRAINT `FK_Reference_3` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`)
) ENGINE=InnoDB AUTO_INCREMENT=3668 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for daily_weight
-- ----------------------------
DROP TABLE IF EXISTS `daily_weight`;
CREATE TABLE `daily_weight` (
  `weightId` bigint(20) NOT NULL AUTO_INCREMENT,
  `userId` bigint(20) DEFAULT NULL,
  `weightAmount` double DEFAULT NULL,
  `time` datetime DEFAULT NULL,
  PRIMARY KEY (`weightId`),
  KEY `FK_Reference_5` (`userId`),
  CONSTRAINT `FK_Reference_5` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for type
-- ----------------------------
DROP TABLE IF EXISTS `type`;
CREATE TABLE `type` (
  `typeId` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) DEFAULT NULL,
  `code` char(40) DEFAULT NULL,
  `addDate` datetime DEFAULT NULL,
  `parentId` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`typeId`),
  KEY `FK_Reference_2` (`parentId`),
  CONSTRAINT `FK_Reference_2` FOREIGN KEY (`parentId`) REFERENCES `type` (`typeId`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `userId` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) DEFAULT NULL,
  `username` varchar(40) DEFAULT NULL,
  `password` varchar(400) DEFAULT NULL,
  `sex` varchar(10) DEFAULT NULL,
  `demo` varchar(20000) DEFAULT NULL,
  `birthday` date DEFAULT NULL,
  `IdNum` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`userId`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES ('1', '用户A', 'user1', null, '男', '帅哥', '2015-08-31', null);
INSERT INTO `users` VALUES ('2', '用户B', 'user2', null, '女', '美女', '2015-10-14', null);

DROP TRIGGER IF EXISTS `budget_add_trigger`;
DELIMITER ;;
CREATE TRIGGER `budget_add_trigger` BEFORE INSERT ON `budget` FOR EACH ROW begin
SELECT sum(amount) into @totalAmount from daily_spend d where d.typeId = New.typeId and d.date>=NEW.startDate and d.date<=NEW.endDate;
set NEW.realAmount = @totalAmount;
set new.difference = new.budgetAmount - new.realAmount;
set new.lastUpdate = now();
set new.realPercent = (new.realAmount/new.budgetAmount)*100;
end
;;
DELIMITER ;
DROP TRIGGER IF EXISTS `budget_edit_trigger`;
DELIMITER ;;
CREATE TRIGGER `budget_edit_trigger` BEFORE UPDATE ON `budget` FOR EACH ROW begin
SELECT sum(amount) into @totalAmount from daily_spend d where d.typeId = New.typeId and d.date>=NEW.startDate and d.date<=NEW.endDate;
set NEW.realAmount = @totalAmount;
set new.difference = new.budgetAmount - new.realAmount;
set new.lastUpdate = now();
set new.realPercent = (new.realAmount/new.budgetAmount)*100;
end
;;
DELIMITER ;
DROP TRIGGER IF EXISTS `dailySpend_add_trigger`;
DELIMITER ;;
CREATE TRIGGER `dailySpend_add_trigger` AFTER INSERT ON `daily_spend` FOR EACH ROW begin
declare done int;
declare _budgetId bigint;
DECLARE ds_cursor CURSOR FOR select budgetId from budget b where b.typeId = new.typeId and b.startDate <= new.date and b.endDate>=new.date;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;
open ds_cursor;
cursor_loop:loop
   FETCH ds_cursor into _budgetId;
   if done=1 then
    leave cursor_loop;
   end if;
   -- 更新表,且此处只需要触发budget表的edit触发器即可
   UPDATE budget set realAmount=2 where budgetId=_budgetId;
end loop cursor_loop;
close ds_cursor;
end
;;
DELIMITER ;
DROP TRIGGER IF EXISTS `dailySpend_edit_trigger`;
DELIMITER ;;
CREATE TRIGGER `dailySpend_edit_trigger` AFTER UPDATE ON `daily_spend` FOR EACH ROW begin
declare done int;
declare _budgetId bigint;
DECLARE ds_cursor CURSOR FOR select budgetId from budget b where b.typeId in (new.typeId,old.typeId) and b.startDate <= new.date and b.endDate>=new.date;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;
open ds_cursor;
cursor_loop:loop
   FETCH ds_cursor into _budgetId;
   if done=1 then
    leave cursor_loop;
   end if;
   -- 更新表,且此处只需要触发budget表的edit触发器即可
   UPDATE budget set realAmount=2 where budgetId=_budgetId;
end loop cursor_loop;
close ds_cursor;
end
;;
DELIMITER ;
DROP TRIGGER IF EXISTS `dailySpend_delete_trigger`;
DELIMITER ;;
CREATE TRIGGER `dailySpend_delete_trigger` AFTER DELETE ON `daily_spend` FOR EACH ROW begin
declare done int;
declare _budgetId bigint;
DECLARE ds_cursor CURSOR FOR select budgetId from budget b where b.typeId = old.typeId and b.startDate <= old.date and b.endDate>=old.date;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done=1;
open ds_cursor;
cursor_loop:loop
   FETCH ds_cursor into _budgetId;
   if done=1 then
    leave cursor_loop;
   end if;
   -- 更新表,且此处只需要触发budget表的edit触发器即可
   UPDATE budget set realAmount=2 where budgetId=_budgetId;
end loop cursor_loop;
close ds_cursor;
end
;;
DELIMITER ;
