/*
 Navicat Premium Data Transfer

 Source Server         : test
 Source Server Type    : MySQL
 Source Server Version : 80027 (8.0.27)
 Source Host           : localhost:3306
 Source Schema         : white_board1

 Target Server Type    : MySQL
 Target Server Version : 80027 (8.0.27)
 File Encoding         : 65001

 Date: 13/11/2022 23:31:57
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for color
-- ----------------------------
DROP TABLE IF EXISTS `color`;
CREATE TABLE `color` (
  `color_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '颜色id',
  `r` float DEFAULT NULL COMMENT 'red',
  `g` float DEFAULT NULL COMMENT 'green',
  `b` float DEFAULT NULL COMMENT 'blue',
  `a` float DEFAULT NULL COMMENT 'alpha',
  PRIMARY KEY (`color_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of color
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for image
-- ----------------------------
DROP TABLE IF EXISTS `image`;
CREATE TABLE `image` (
  `image_num` int NOT NULL COMMENT '每个图形唯一标识id',
  `room_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '房间id',
  `user_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '用户id',
  `image_id` int DEFAULT NULL COMMENT '图片类型',
  `current_page` int DEFAULT NULL COMMENT '当前页数',
  `x` float DEFAULT NULL COMMENT '图片左上角x坐标',
  `y` float DEFAULT NULL COMMENT '图片左上角y坐标',
  `locked` tinyint(1) DEFAULT NULL COMMENT '是否被锁定',
  `operation_id` int DEFAULT NULL COMMENT '操作id',
  `mid_x` float DEFAULT NULL COMMENT '图片中心点x坐标',
  `mid_y` float DEFAULT NULL COMMENT '图片中心点y坐标',
  `rotate` float DEFAULT NULL COMMENT '旋转角度',
  PRIMARY KEY (`image_num`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of image
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for operation
-- ----------------------------
DROP TABLE IF EXISTS `operation`;
CREATE TABLE `operation` (
  `user_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '用户id',
  `operation_id` int NOT NULL COMMENT '此用户的第几次操作',
  `room_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '房间id',
  `current_page` int DEFAULT NULL COMMENT '此页数',
  `graphical` int DEFAULT NULL COMMENT '图形id',
  `line_width` float DEFAULT NULL COMMENT '线宽',
  `hidden` tinyint(1) DEFAULT NULL COMMENT '是否被隐藏',
  `color_id` int DEFAULT NULL COMMENT '颜色id',
  PRIMARY KEY (`user_id`,`operation_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of operation
-- ----------------------------
BEGIN;
INSERT INTO `operation` (`user_id`, `operation_id`, `room_id`, `current_page`, `graphical`, `line_width`, `hidden`, `color_id`) VALUES ('13241', 0, NULL, NULL, NULL, NULL, NULL, NULL);
COMMIT;

-- ----------------------------
-- Table structure for r1234p_1
-- ----------------------------
DROP TABLE IF EXISTS `r1234p_1`;
CREATE TABLE `r1234p_1` (
  `x` float NOT NULL COMMENT 'x坐标',
  `y` float NOT NULL COMMENT 'y坐标',
  `operation_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '操作id',
  `color_id` int DEFAULT NULL COMMENT '颜色id',
  PRIMARY KEY (`x`,`y`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of r1234p_1
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for r1456p_2
-- ----------------------------
DROP TABLE IF EXISTS `r1456p_2`;
CREATE TABLE `r1456p_2` (
  `operation_id` int DEFAULT NULL,
  `x` float NOT NULL,
  `y` float NOT NULL,
  `color_id` int DEFAULT NULL,
  PRIMARY KEY (`x`,`y`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of r1456p_2
-- ----------------------------
BEGIN;
COMMIT;

-- ----------------------------
-- Table structure for room
-- ----------------------------
DROP TABLE IF EXISTS `room`;
CREATE TABLE `room` (
  `room_id` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '房间id',
  `page_count` int DEFAULT NULL COMMENT '房间总页数',
  `current_page` int DEFAULT NULL COMMENT '此页数',
  `people_num` int DEFAULT NULL COMMENT '房间总人数',
  PRIMARY KEY (`room_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of room
-- ----------------------------
BEGIN;
INSERT INTO `room` (`room_id`, `page_count`, `current_page`, `people_num`) VALUES ('1234', 12, 1, 13);
INSERT INTO `room` (`room_id`, `page_count`, `current_page`, `people_num`) VALUES ('651830764321', 1, 1, 1);
INSERT INTO `room` (`room_id`, `page_count`, `current_page`, `people_num`) VALUES ('8888', 88, 8, 8);
INSERT INTO `room` (`room_id`, `page_count`, `current_page`, `people_num`) VALUES ('9999', 99, 9, 9);
COMMIT;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `user_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '用户id',
  `room_id` varchar(32) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '用户所在房间',
  `authority` int DEFAULT NULL COMMENT '用户权限',
  `operation_num` int DEFAULT NULL COMMENT '操作总次数',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

-- ----------------------------
-- Records of user
-- ----------------------------
BEGIN;
INSERT INTO `user` (`user_id`, `room_id`, `authority`, `operation_num`) VALUES ('123', '123', 1, 0);
INSERT INTO `user` (`user_id`, `room_id`, `authority`, `operation_num`) VALUES ('user1668313539', '651830764321', 1, 0);
COMMIT;

-- ----------------------------
-- View structure for r1234p_1points
-- ----------------------------
DROP VIEW IF EXISTS `r1234p_1points`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `r1234p_1points` AS select `color`.`r` AS `r`,`color`.`g` AS `g`,`color`.`b` AS `b`,`color`.`a` AS `a`,`r1234p_1`.`x` AS `x`,`r1234p_1`.`y` AS `y` from (`color` join `r1234p_1`) where (`color`.`color_id` = `r1234p_1`.`color_id`);

-- ----------------------------
-- View structure for r1234p_1points_visible
-- ----------------------------
DROP VIEW IF EXISTS `r1234p_1points_visible`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `r1234p_1points_visible` AS select `color`.`r` AS `r`,`color`.`g` AS `g`,`color`.`b` AS `b`,`color`.`a` AS `a`,`r1234p_1`.`x` AS `x`,`r1234p_1`.`y` AS `y` from ((`color` join `r1234p_1`) join `operation`) where ((`r1234p_1`.`operation_id` = `operation`.`operation_id`) and (`operation`.`operation_id` = 0) and (`color`.`color_id` = `r1234p_1`.`color_id`));

SET FOREIGN_KEY_CHECKS = 1;
