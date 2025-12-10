-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: study_cafe
-- ------------------------------------------------------
-- Server version	8.0.41

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `branch`
--

DROP TABLE IF EXISTS `branch`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `branch` (
  `branch_id` bigint NOT NULL AUTO_INCREMENT COMMENT '지점ID',
  `company_id` bigint NOT NULL COMMENT '(FK) 본점ID',
  `branch_name` varchar(255) NOT NULL COMMENT '지점명',
  `location` varchar(255) DEFAULT NULL COMMENT '지점 주소',
  `open_time` time DEFAULT NULL COMMENT '오픈시간',
  `close_time` time DEFAULT NULL COMMENT '마감시간',
  PRIMARY KEY (`branch_id`),
  KEY `company_id` (`company_id`),
  CONSTRAINT `branch_ibfk_1` FOREIGN KEY (`company_id`) REFERENCES `company` (`company_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='각 지점 정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch`
--

LOCK TABLES `branch` WRITE;
/*!40000 ALTER TABLE `branch` DISABLE KEYS */;
INSERT INTO `branch` VALUES (1,1,'서울캠퍼스점','서울시 중구',NULL,NULL),(2,1,'홍대점','서울시 마포구',NULL,NULL),(3,1,'성수점','서울시 성동구',NULL,NULL),(4,1,'건대점','서울시 광진구',NULL,NULL),(5,1,'신촌점','서울시 서대문구',NULL,NULL);
/*!40000 ALTER TABLE `branch` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company`
--

DROP TABLE IF EXISTS `company`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company` (
  `company_id` bigint NOT NULL AUTO_INCREMENT COMMENT '본점ID',
  `company_name` varchar(255) NOT NULL COMMENT '본사명',
  PRIMARY KEY (`company_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='본사(프랜차이즈) 정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company`
--

LOCK TABLES `company` WRITE;
/*!40000 ALTER TABLE `company` DISABLE KEYS */;
INSERT INTO `company` VALUES (1,'동국스터디카페 본점');
/*!40000 ALTER TABLE `company` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `coupon`
--

DROP TABLE IF EXISTS `coupon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupon` (
  `coupon_id` bigint NOT NULL AUTO_INCREMENT COMMENT '쿠폰ID',
  `coupon_name` varchar(255) NOT NULL COMMENT '쿠폰명',
  `discount_type` varchar(50) NOT NULL COMMENT '''Fixed''(정액), ''Percentage''(정률)',
  `discount_value` int NOT NULL DEFAULT '0' COMMENT '할인값',
  `validity_type` varchar(50) NOT NULL COMMENT '''Date''(만료일), ''Period''(기간)',
  `expiry_date` timestamp NULL DEFAULT NULL COMMENT '''Date'' 타입일 때 만료 일시',
  `valid_days` int DEFAULT NULL COMMENT '''Period'' 타입일 때 유효 일수',
  PRIMARY KEY (`coupon_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='쿠폰 마스터 (설계도)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupon`
--

LOCK TABLES `coupon` WRITE;
/*!40000 ALTER TABLE `coupon` DISABLE KEYS */;
INSERT INTO `coupon` VALUES (1,'[오픈이벤트] 5,000원 할인','Fixed',5000,'Date',NULL,NULL),(2,'[전지점] 사물함 50% 할인','Percentage',50,'Period',NULL,NULL),(3,'[재방문] 10% 감사 쿠폰','Percentage',10,'Period',NULL,NULL);
/*!40000 ALTER TABLE `coupon` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `daily_reservation_status`
--

DROP TABLE IF EXISTS `daily_reservation_status`;
/*!50001 DROP VIEW IF EXISTS `daily_reservation_status`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `daily_reservation_status` AS SELECT 
 1 AS `시작시간`,
 1 AS `회원이름`,
 1 AS `좌석번호`,
 1 AS `상태`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `equipment`
--

DROP TABLE IF EXISTS `equipment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `equipment` (
  `equipment_id` bigint NOT NULL AUTO_INCREMENT COMMENT '장비ID',
  `room_id` bigint NOT NULL COMMENT '(FK) 룸ID (1:N 관계)',
  `equipment_name` varchar(255) NOT NULL COMMENT 'e.g., ''프로젝터''',
  PRIMARY KEY (`equipment_id`),
  KEY `room_id` (`room_id`),
  CONSTRAINT `equipment_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `room` (`room_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='스터디룸 비품 (1:N)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `equipment`
--

LOCK TABLES `equipment` WRITE;
/*!40000 ALTER TABLE `equipment` DISABLE KEYS */;
/*!40000 ALTER TABLE `equipment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locker`
--

DROP TABLE IF EXISTS `locker`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `locker` (
  `locker_id` bigint NOT NULL AUTO_INCREMENT COMMENT '사물함ID',
  `branch_id` bigint NOT NULL COMMENT '(FK) 지점ID',
  `locker_number` varchar(50) NOT NULL COMMENT '사물함 번호 (e.g., S-10)',
  `locker_size` varchar(50) DEFAULT NULL COMMENT '''Small'', ''Medium''',
  `status` varchar(50) NOT NULL DEFAULT 'Available' COMMENT '''Available'', ''InUse''',
  PRIMARY KEY (`locker_id`),
  KEY `branch_id` (`branch_id`),
  CONSTRAINT `locker_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branch` (`branch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=213 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='사물함 자산';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locker`
--

LOCK TABLES `locker` WRITE;
/*!40000 ALTER TABLE `locker` DISABLE KEYS */;
INSERT INTO `locker` VALUES (1,2,'201','Medium','Available'),(2,1,'101','Small','Available'),(3,1,'102','Small','Available'),(4,1,'103','Small','Available'),(5,1,'104','Small','Available'),(6,1,'105','Small','Available'),(7,1,'106','Small','Available'),(8,1,'107','Small','Available'),(9,1,'108','Small','Available'),(10,1,'109','Small','Available'),(11,1,'110','Small','Available'),(12,1,'111','Small','Available'),(13,1,'112','Small','Available'),(14,1,'113','Small','Available'),(15,1,'114','Small','Available'),(16,1,'115','Small','Available'),(17,1,'116','Medium','Available'),(18,1,'117','Medium','Available'),(19,1,'118','Medium','Available'),(20,1,'119','Medium','Available'),(21,1,'120','Medium','Available'),(22,1,'121','Medium','Available'),(23,1,'122','Medium','Available'),(24,1,'123','Medium','Available'),(25,1,'124','Medium','Available'),(26,1,'125','Medium','Available'),(27,3,'301','Medium','Available'),(28,3,'302','Medium','Available'),(29,3,'303','Medium','Available'),(30,3,'304','Medium','Available'),(31,3,'305','Medium','Available'),(32,3,'306','Medium','Available'),(33,3,'307','Medium','Available'),(34,3,'308','Small','Available'),(35,3,'309','Small','Available'),(36,3,'310','Small','Available'),(37,4,'401','Medium','Available'),(38,4,'402','Medium','Available'),(39,4,'403','Medium','Available'),(40,4,'404','Medium','Available'),(41,4,'405','Medium','Available'),(42,4,'406','Medium','Available'),(43,4,'407','Medium','Available'),(44,4,'408','Medium','Available'),(45,4,'409','Medium','Available'),(46,4,'410','Medium','Available'),(47,4,'411','Small','Available'),(48,4,'412','Small','Available'),(49,4,'413','Small','Available'),(50,4,'414','Small','Available'),(51,4,'415','Small','Available'),(52,4,'416','Small','Available'),(53,4,'417','Small','Available'),(54,4,'418','Small','Available'),(55,4,'419','Small','Available'),(56,4,'420','Small','Available'),(57,5,'501','Medium','Available'),(58,5,'502','Medium','Available'),(59,5,'503','Medium','Available'),(60,5,'504','Medium','Available'),(61,5,'505','Medium','Available'),(62,5,'506','Medium','Available'),(63,5,'507','Medium','Available'),(64,5,'508','Medium','Available'),(65,5,'509','Medium','Available'),(66,5,'510','Medium','Available'),(67,5,'511','Small','Available'),(68,5,'512','Small','Available'),(69,5,'513','Small','Available'),(70,5,'514','Small','Available'),(71,5,'515','Small','Available'),(72,5,'516','Small','Available'),(73,5,'517','Small','Available'),(74,5,'518','Small','Available'),(75,5,'519','Small','Available'),(76,5,'520','Small','Available'),(77,5,'521','Small','Available'),(78,5,'522','Small','Available'),(79,5,'523','Small','Available'),(80,5,'524','Small','Available'),(81,5,'525','Small','Available'),(82,5,'526','Small','Available'),(83,5,'527','Small','Available'),(84,5,'528','Small','Available'),(85,5,'529','Small','Available'),(86,5,'530','Small','Available'),(87,1,'101','Small','Available'),(88,1,'102','Small','Available'),(89,1,'103','Small','Available'),(90,1,'104','Small','Available'),(91,1,'105','Small','Available'),(92,1,'106','Small','Available'),(93,1,'107','Small','Available'),(94,1,'108','Small','Available'),(95,1,'109','Small','Available'),(96,1,'110','Small','Available'),(97,1,'111','Small','Available'),(98,1,'112','Small','Available'),(99,1,'113','Small','Available'),(100,1,'114','Small','Available'),(101,1,'115','Small','Available'),(102,1,'116','Medium','Available'),(103,1,'117','Medium','Available'),(104,1,'118','Medium','Available'),(105,1,'119','Medium','Available'),(106,1,'120','Medium','Available'),(107,1,'121','Medium','Available'),(108,1,'122','Medium','Available'),(109,1,'123','Medium','Available'),(110,1,'124','Medium','Available'),(111,1,'125','Medium','Available'),(112,3,'301','Medium','Available'),(113,3,'302','Medium','Available'),(114,3,'303','Medium','Available'),(115,3,'304','Medium','Available'),(116,3,'305','Medium','Available'),(117,3,'306','Medium','Available'),(118,3,'307','Medium','Available'),(119,3,'308','Small','Available'),(120,3,'309','Small','Available'),(121,3,'310','Small','Available'),(122,4,'401','Medium','Available'),(123,4,'402','Medium','Available'),(124,4,'403','Medium','Available'),(125,4,'404','Medium','Available'),(126,4,'405','Medium','Available'),(127,4,'406','Medium','Available'),(128,4,'407','Medium','Available'),(129,4,'408','Medium','Available'),(130,4,'409','Medium','Available'),(131,4,'410','Medium','Available'),(132,4,'411','Small','Available'),(133,4,'412','Small','Available'),(134,4,'413','Small','Available'),(135,4,'414','Small','Available'),(136,4,'415','Small','Available'),(137,4,'416','Small','Available'),(138,4,'417','Small','Available'),(139,4,'418','Small','Available'),(140,4,'419','Small','Available'),(141,4,'420','Small','Available'),(142,5,'501','Medium','Available'),(143,5,'502','Medium','Available'),(144,5,'503','Medium','Available'),(145,5,'504','Medium','Available'),(146,5,'505','Medium','Available'),(147,5,'506','Medium','Available'),(148,5,'507','Medium','Available'),(149,5,'508','Medium','Available'),(150,5,'509','Medium','Available'),(151,5,'510','Medium','Available'),(152,5,'511','Small','Available'),(153,5,'512','Small','Available'),(154,5,'513','Small','Available'),(155,5,'514','Small','Available'),(156,5,'515','Small','Available'),(157,5,'516','Small','Available'),(158,5,'517','Small','Available'),(159,5,'518','Small','Available'),(160,5,'519','Small','Available'),(161,5,'520','Small','Available'),(162,5,'521','Small','Available'),(163,5,'522','Small','Available'),(164,5,'523','Small','Available'),(165,5,'524','Small','Available'),(166,5,'525','Small','Available'),(167,5,'526','Small','Available'),(168,5,'527','Small','Available'),(169,5,'528','Small','Available'),(170,5,'529','Small','Available'),(171,5,'530','Small','Available'),(172,2,'101','Medium','Available'),(173,2,'102','Medium','Available'),(174,2,'103','Medium','Available'),(175,2,'104','Medium','Available'),(176,2,'105','Medium','InUse'),(177,2,'106','Medium','InUse'),(178,2,'107','Medium','Available'),(179,2,'108','Medium','Available'),(180,2,'109','Small','Available'),(181,2,'110','Small','Available'),(182,2,'111','Small','Available'),(183,2,'112','Small','Available'),(184,2,'113','Small','Available'),(185,2,'114','Small','Available'),(186,2,'115','Small','Available'),(187,2,'116','Small','Available'),(188,2,'117','Small','Available'),(189,2,'118','Small','Available'),(190,2,'119','Small','Available'),(191,2,'120','Small','Available'),(192,2,'101','Medium','Available'),(193,2,'102','Medium','Available'),(194,2,'103','Medium','Available'),(195,2,'104','Medium','Available'),(196,2,'105','Medium','InUse'),(197,2,'106','Medium','InUse'),(198,2,'107','Medium','Available'),(199,2,'108','Medium','Available'),(200,2,'109','Small','Available'),(201,2,'110','Small','Available'),(202,2,'111','Small','InUse'),(203,2,'112','Small','Available'),(204,2,'113','Small','Available'),(205,2,'114','Small','Available'),(206,2,'115','Small','Available'),(207,2,'116','Small','Available'),(208,2,'117','Small','Available'),(209,2,'118','Small','Available'),(210,2,'119','Small','Available'),(211,2,'120','Small','Available'),(212,2,'201','Medium','Available');
/*!40000 ALTER TABLE `locker` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `member`
--

DROP TABLE IF EXISTS `member`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `member` (
  `member_id` bigint NOT NULL AUTO_INCREMENT COMMENT '회원ID',
  `password` varchar(255) NOT NULL COMMENT '비밀번호',
  `member_name` varchar(100) NOT NULL COMMENT '이름',
  `phone_number` varchar(50) NOT NULL COMMENT '연락처 (UNIQUE)',
  `email` varchar(255) NOT NULL COMMENT '이메일 (UNIQUE)',
  `member_grade` varchar(50) NOT NULL DEFAULT 'General' COMMENT '''General'', ''Admin''',
  `join_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '가입일시',
  `status` varchar(50) NOT NULL DEFAULT 'Active' COMMENT '''Active'', ''Withdrawn''',
  `current_points` int NOT NULL DEFAULT '0' COMMENT '보유포인트',
  PRIMARY KEY (`member_id`),
  UNIQUE KEY `phone_number` (`phone_number`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=110 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='회원 정보';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `member`
--

LOCK TABLES `member` WRITE;
/*!40000 ALTER TABLE `member` DISABLE KEYS */;
INSERT INTO `member` VALUES (1,'1234','이지은','010-1234-5678','jieun@dongguk.edu','General','2025-12-01 01:00:00','Active',5000),(99,'1234','김철수','010-9999-9999','ghost@test.com','General','2024-12-31 15:00:00','Active',0),(101,'1234','테스트유저1','010-1111-1111','user1','General','2025-12-10 15:28:54','Active',0),(102,'1234','테스트유저2','010-2222-2222','user2','General','2023-12-31 15:00:00','Active',10000),(103,'1234','테스트유저3','010-3333-3333','user3','General','2024-01-01 01:00:00','Active',0),(104,'1234','테스트유저4','010-4444-4444','user4','General','2024-02-15 05:00:00','Active',5000),(105,'1234','테스트유저5','010-5555-5555','user5','General','2024-03-01 00:00:00','Active',10000),(106,'1234','테스트유저6','010-6666-6666','user6','General','2024-11-01 02:00:00','Active',0),(107,'1234','테스트유저7','010-7777-7777','user7','General','2024-12-01 06:00:00','Active',2000),(108,'1234','테스트유저8','010-8888-8888','user8','General','2025-12-10 15:50:51','Active',0),(109,'1234','테스트유저9','010-9090-9090','user9','General','2025-12-10 15:50:51','Active',500);
/*!40000 ALTER TABLE `member` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `member_coupon`
--

DROP TABLE IF EXISTS `member_coupon`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `member_coupon` (
  `member_coupon_id` bigint NOT NULL AUTO_INCREMENT COMMENT '회원쿠폰ID',
  `member_id` bigint NOT NULL COMMENT '(FK) 회원ID',
  `coupon_id` bigint NOT NULL COMMENT '(FK) 쿠폰ID',
  `issue_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '쿠폰 발급 일시',
  `status` varchar(50) NOT NULL DEFAULT 'Available' COMMENT '''Available'', ''Used''',
  PRIMARY KEY (`member_coupon_id`),
  KEY `member_id` (`member_id`),
  KEY `coupon_id` (`coupon_id`),
  CONSTRAINT `member_coupon_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`),
  CONSTRAINT `member_coupon_ibfk_2` FOREIGN KEY (`coupon_id`) REFERENCES `coupon` (`coupon_id`)
) ENGINE=InnoDB AUTO_INCREMENT=38 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='회원이 실제 소유한 쿠폰 (실물)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `member_coupon`
--

LOCK TABLES `member_coupon` WRITE;
/*!40000 ALTER TABLE `member_coupon` DISABLE KEYS */;
INSERT INTO `member_coupon` VALUES (1,101,1,'2025-12-10 15:53:46','Available'),(2,1,1,'2025-12-10 15:53:46','Available'),(3,102,1,'2025-12-10 15:53:46','Available'),(4,103,1,'2025-12-10 15:53:46','Available'),(5,104,1,'2025-12-10 15:53:46','Available'),(6,105,1,'2025-12-10 15:53:46','Available'),(7,106,1,'2025-12-10 15:53:46','Available'),(8,107,1,'2025-12-10 15:53:46','Available'),(9,108,1,'2025-12-10 15:53:46','Available'),(10,109,1,'2025-12-10 15:53:46','Available'),(11,99,1,'2025-12-10 15:53:46','Available'),(16,101,3,'2025-12-10 15:53:46','Available'),(17,1,3,'2025-12-10 15:53:46','Available'),(18,102,3,'2025-12-10 15:53:46','Available'),(19,103,3,'2025-12-10 15:53:46','Available'),(20,104,3,'2025-12-10 15:53:46','Available'),(21,105,3,'2025-12-10 15:53:46','Available'),(22,106,3,'2025-12-10 15:53:46','Available'),(23,107,3,'2025-12-10 15:53:46','Available'),(24,108,3,'2025-12-10 15:53:46','Available'),(25,109,3,'2025-12-10 15:53:46','Available'),(26,99,3,'2025-12-10 15:53:46','Available'),(31,1,2,'2025-12-10 15:53:46','Available'),(32,101,2,'2025-12-10 15:53:46','Available'),(33,108,2,'2025-12-10 15:53:46','Available'),(34,109,2,'2025-12-10 15:53:46','Available');
/*!40000 ALTER TABLE `member_coupon` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment`
--

DROP TABLE IF EXISTS `payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment` (
  `payment_id` bigint NOT NULL AUTO_INCREMENT COMMENT '결제(영수증) ID',
  `member_id` bigint NOT NULL COMMENT '(FK) 결제한 회원ID',
  `final_amount` int NOT NULL DEFAULT '0' COMMENT '최종 결제액',
  `payment_method` varchar(100) NOT NULL COMMENT '결제 수단',
  `used_points` int NOT NULL DEFAULT '0' COMMENT '사용한 포인트',
  `member_coupon_id` bigint DEFAULT NULL COMMENT '(FK) 사용한 쿠폰ID (1:1)',
  `payment_datetime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `member_coupon_id` (`member_coupon_id`),
  KEY `member_id` (`member_id`),
  CONSTRAINT `payment_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`),
  CONSTRAINT `payment_ibfk_2` FOREIGN KEY (`member_coupon_id`) REFERENCES `member_coupon` (`member_coupon_id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='결제 영수증 (1:N 예약의 "1" 쪽)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment`
--

LOCK TABLES `payment` WRITE;
/*!40000 ALTER TABLE `payment` DISABLE KEYS */;
INSERT INTO `payment` VALUES (1,1,9500,'CreditCard',0,3,'2025-12-10 14:41:30'),(2,1,9000,'CreditCard',0,NULL,'2025-12-10 14:43:29'),(3,1,30000,'CreditCard',0,NULL,'2025-12-10 14:46:36'),(4,1,14000,'CreditCard',0,NULL,'2025-12-10 14:46:58'),(5,1,9000,'CreditCard',0,NULL,'2025-12-10 14:55:44'),(6,1,14000,'CreditCard',0,NULL,'2025-12-10 14:56:20'),(7,1,30000,'CreditCard',0,NULL,'2025-12-10 15:00:54'),(8,1,133000,'CreditCard',0,NULL,'2025-12-10 15:12:14'),(9,1,14000,'CreditCard',0,NULL,'2025-12-10 15:13:26'),(10,1,19000,'CreditCard',0,NULL,'2025-12-10 15:23:32'),(11,101,30000,'CreditCard',0,NULL,'2025-12-10 15:29:44'),(12,101,14000,'CreditCard',0,NULL,'2025-12-10 15:31:09'),(13,101,23000,'CreditCard',0,NULL,'2025-12-10 15:34:11'),(14,101,14000,'CreditCard',0,NULL,'2025-12-10 15:35:44'),(15,101,19000,'CreditCard',0,NULL,'2025-12-10 15:45:53'),(16,101,9000,'CreditCard',0,NULL,'2025-12-10 15:46:06');
/*!40000 ALTER TABLE `payment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `point_history`
--

DROP TABLE IF EXISTS `point_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `point_history` (
  `point_history_id` bigint NOT NULL AUTO_INCREMENT COMMENT '포인트내역ID',
  `member_id` bigint NOT NULL COMMENT '(FK) 회원ID',
  `reservation_id` bigint DEFAULT NULL COMMENT '(FK) 관련 예약ID',
  `change_type` varchar(50) NOT NULL COMMENT '''Earned''(적립), ''Used''(사용)',
  `amount` int NOT NULL DEFAULT '0' COMMENT '포인트 변동량',
  `transaction_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`point_history_id`),
  KEY `member_id` (`member_id`),
  KEY `reservation_id` (`reservation_id`),
  CONSTRAINT `point_history_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`),
  CONSTRAINT `point_history_ibfk_2` FOREIGN KEY (`reservation_id`) REFERENCES `reservation` (`reservation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='포인트 변동 내역';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `point_history`
--

LOCK TABLES `point_history` WRITE;
/*!40000 ALTER TABLE `point_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `point_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `product_id` bigint NOT NULL AUTO_INCREMENT COMMENT '상품ID',
  `product_name` varchar(255) NOT NULL COMMENT 'e.g., ''당일권 2시간''',
  `product_type` varchar(100) NOT NULL COMMENT '''SEAT'', ''ROOM'', ''LOCKER''',
  `price` int NOT NULL DEFAULT '0' COMMENT '상품 정가',
  `hours` int DEFAULT NULL COMMENT '시간 단위 상품',
  `days` int DEFAULT NULL COMMENT '일 단위 상품',
  `fixed_time_hours` int DEFAULT NULL COMMENT '정액권 상품',
  PRIMARY KEY (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='판매 상품 카탈로그 (전 지점 공통)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (6,'당일권 2시간','SEAT',4000,2,NULL,NULL),(7,'당일권 4시간','SEAT',5000,4,NULL,NULL),(8,'당일권 8시간','SEAT',9000,8,NULL,NULL),(9,'당일권 14시간','SEAT',12000,14,NULL,NULL),(10,'정액권 50시간','SEAT',65000,NULL,NULL,50),(11,'정액권 100시간','SEAT',118000,NULL,NULL,100),(12,'정액권 200시간','SEAT',198000,NULL,NULL,200),(13,'정액권 300시간','SEAT',278000,NULL,NULL,300),(14,'자유석 기간권 1주','SEAT',58000,NULL,7,NULL),(15,'자유석 기간권 4주','SEAT',128000,NULL,28,NULL),(16,'자유석 기간권 12주','SEAT',325000,NULL,84,NULL),(17,'지정석 1일권','SEAT',14000,NULL,1,NULL),(18,'지정석 4주권','SEAT',158000,NULL,28,NULL),(19,'지정석 12주권','SEAT',426000,NULL,84,NULL),(20,'사물함 1일권','LOCKER',5000,NULL,1,NULL),(21,'사물함 4주권','LOCKER',9000,NULL,28,NULL),(22,'사물함 12주권','LOCKER',24300,NULL,84,NULL),(23,'포커스룸(2인) 1시간','ROOM',5000,1,NULL,NULL),(24,'미팅룸(4인) 1시간','ROOM',10000,1,NULL,NULL),(25,'미팅룸(6인) 1시간','ROOM',15000,1,NULL,NULL),(26,'세미나룸(단체) 1시간','ROOM',25000,1,NULL,NULL);
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reservation`
--

DROP TABLE IF EXISTS `reservation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reservation` (
  `reservation_id` bigint NOT NULL AUTO_INCREMENT COMMENT '통합 예약/거래 ID',
  `member_id` bigint NOT NULL COMMENT '(FK) 예약한 회원ID',
  `product_id` bigint NOT NULL COMMENT '(FK) 구매한 상품ID',
  `room_id` bigint DEFAULT NULL COMMENT '(FK) 예약된 룸ID',
  `seat_id` bigint DEFAULT NULL COMMENT '(FK) 점유된 좌석ID',
  `locker_id` bigint DEFAULT NULL COMMENT '(FK) 대여된 사물함ID',
  `payment_id` bigint DEFAULT NULL COMMENT '(FK) 묶인 결제(영수증)ID',
  `start_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '이용 시작 일시',
  `end_datetime` datetime DEFAULT NULL COMMENT '이용 종료/만료 일시',
  `remaining_hours` int DEFAULT NULL COMMENT '정액권 남은 시간',
  `total_fee` int NOT NULL DEFAULT '0' COMMENT '할인 전 총 요금',
  `status` varchar(50) NOT NULL DEFAULT 'InCart' COMMENT '''InCart'', ''Confirmed'' 등',
  PRIMARY KEY (`reservation_id`),
  KEY `member_id` (`member_id`),
  KEY `product_id` (`product_id`),
  KEY `room_id` (`room_id`),
  KEY `seat_id` (`seat_id`),
  KEY `locker_id` (`locker_id`),
  KEY `payment_id` (`payment_id`),
  CONSTRAINT `reservation_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`),
  CONSTRAINT `reservation_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `product` (`product_id`),
  CONSTRAINT `reservation_ibfk_3` FOREIGN KEY (`room_id`) REFERENCES `room` (`room_id`),
  CONSTRAINT `reservation_ibfk_4` FOREIGN KEY (`seat_id`) REFERENCES `seat` (`seat_id`),
  CONSTRAINT `reservation_ibfk_5` FOREIGN KEY (`locker_id`) REFERENCES `locker` (`locker_id`),
  CONSTRAINT `reservation_ibfk_6` FOREIGN KEY (`payment_id`) REFERENCES `payment` (`payment_id`)
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='핵심 허브 (장바구니 항목)';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reservation`
--

LOCK TABLES `reservation` WRITE;
/*!40000 ALTER TABLE `reservation` DISABLE KEYS */;
INSERT INTO `reservation` VALUES (2,99,24,3,NULL,NULL,NULL,'2025-12-28 05:00:00','2025-12-28 07:00:00',NULL,20000,'Scheduled'),(3,99,17,NULL,142,NULL,NULL,'2025-12-01 00:00:00','2025-12-31 23:59:59',NULL,150000,'Scheduled'),(4,1,17,NULL,145,NULL,1,'2025-12-27 15:00:00','2025-12-28 14:59:59',NULL,14000,'InUse'),(5,1,20,NULL,NULL,NULL,1,'2025-12-10 23:24:09','2026-01-07 23:24:09',NULL,5000,'Scheduled'),(7,1,8,NULL,145,NULL,2,'2025-12-27 15:00:00','2025-12-28 14:59:59',NULL,9000,'InUse'),(8,1,24,2,NULL,NULL,3,'2025-12-10 12:00:00','2025-12-10 15:00:00',NULL,30000,'InUse'),(9,1,17,NULL,61,NULL,4,'2025-12-10 00:00:00','2025-12-10 23:59:59',NULL,14000,'InUse'),(10,1,8,NULL,NULL,NULL,5,'2025-12-10 00:00:00','2025-12-10 23:59:59',NULL,9000,'Scheduled'),(11,1,17,NULL,81,NULL,6,'2025-12-10 00:00:00','2025-12-10 23:59:59',NULL,14000,'InUse'),(12,1,24,3,NULL,NULL,7,'2025-12-10 12:00:00','2025-12-10 15:00:00',NULL,30000,'Scheduled'),(13,1,15,NULL,32,NULL,8,'2025-12-10 00:00:00','2025-12-10 23:59:59',NULL,128000,'Active'),(14,1,20,NULL,NULL,NULL,8,'2025-12-11 00:12:13','2026-01-08 00:12:13',NULL,5000,'Scheduled'),(15,1,17,NULL,66,NULL,9,'2025-12-12 15:00:00','2025-12-13 14:59:59',NULL,14000,'Active'),(16,1,17,NULL,57,NULL,10,'2025-12-27 15:00:00','2025-12-28 14:59:59',NULL,14000,'Active'),(17,1,20,NULL,NULL,NULL,10,'2025-12-11 00:23:31','2026-01-08 00:23:31',NULL,5000,'Scheduled'),(18,99,21,NULL,NULL,NULL,NULL,'2025-12-01 00:00:00','2025-12-31 23:59:59',NULL,9000,'Scheduled'),(19,99,21,NULL,NULL,NULL,NULL,'2025-12-01 00:00:00','2025-12-31 23:59:59',NULL,9000,'Scheduled'),(20,101,24,4,NULL,NULL,11,'2025-12-28 03:00:00','2025-12-28 06:00:00',NULL,30000,'Scheduled'),(21,101,8,NULL,NULL,NULL,12,'2025-12-27 15:00:00','2025-12-28 14:59:59',NULL,9000,'Active'),(22,101,20,NULL,NULL,NULL,12,'2025-12-11 00:38:48','2025-12-12 00:38:48',NULL,5000,'Scheduled'),(23,101,17,NULL,57,NULL,13,'2025-12-11 00:38:53','2025-12-12 00:38:53',NULL,14000,'InUse'),(24,101,8,NULL,37,NULL,13,'2025-12-11 00:44:03','2025-12-11 08:44:03',NULL,9000,'InUse'),(25,101,17,NULL,46,NULL,14,'2025-12-11 00:43:56','2025-12-12 00:43:56',NULL,14000,'InUse'),(26,101,17,NULL,52,NULL,15,'2025-12-11 00:00:00','2025-12-11 23:59:59',NULL,14000,'Active'),(27,101,20,NULL,NULL,NULL,15,'2025-12-11 00:46:29','2025-12-12 00:46:29',NULL,5000,'Scheduled'),(28,101,8,NULL,NULL,NULL,16,'2025-12-11 00:00:00','2025-12-11 23:59:59',NULL,9000,'Active'),(29,101,18,NULL,62,NULL,NULL,'2025-12-10 00:00:00','2025-12-10 23:59:59',NULL,158000,'InCart');
/*!40000 ALTER TABLE `reservation` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `review`
--

DROP TABLE IF EXISTS `review`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `review` (
  `review_id` bigint NOT NULL AUTO_INCREMENT COMMENT '후기ID',
  `member_id` bigint NOT NULL COMMENT '(FK) 작성한 회원ID',
  `reservation_id` bigint NOT NULL COMMENT '(FK) 리뷰 대상 예약ID (1:1)',
  `rating` int NOT NULL DEFAULT '5' COMMENT '1~5점 별점',
  `content` text COMMENT '후기 텍스트 내용',
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`review_id`),
  UNIQUE KEY `reservation_id` (`reservation_id`),
  KEY `member_id` (`member_id`),
  CONSTRAINT `review_ibfk_1` FOREIGN KEY (`member_id`) REFERENCES `member` (`member_id`),
  CONSTRAINT `review_ibfk_2` FOREIGN KEY (`reservation_id`) REFERENCES `reservation` (`reservation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='예약 건에 대한 1:1 후기';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `review`
--

LOCK TABLES `review` WRITE;
/*!40000 ALTER TABLE `review` DISABLE KEYS */;
/*!40000 ALTER TABLE `review` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `room`
--

DROP TABLE IF EXISTS `room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `room` (
  `room_id` bigint NOT NULL AUTO_INCREMENT COMMENT '룸ID',
  `branch_id` bigint NOT NULL COMMENT '(FK) 지점ID',
  `room_name` varchar(255) NOT NULL COMMENT '룸 이름 (e.g., 6인실 A)',
  `capacity` int NOT NULL DEFAULT '1' COMMENT '수용인원',
  `room_type` varchar(100) NOT NULL COMMENT '상품 매칭용 (e.g., 6인실)',
  `status` varchar(50) NOT NULL DEFAULT 'Available' COMMENT 'Available, InUse',
  PRIMARY KEY (`room_id`),
  KEY `branch_id` (`branch_id`),
  CONSTRAINT `room_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branch` (`branch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='스터디룸(회의실) 자산';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `room`
--

LOCK TABLES `room` WRITE;
/*!40000 ALTER TABLE `room` DISABLE KEYS */;
INSERT INTO `room` VALUES (1,2,'세미나룸',10,'10인실','Available'),(2,3,'미팅룸 A',4,'4인실','Available'),(3,2,'미팅룸 A',4,'4인실','Available'),(4,2,'미팅룸 B',4,'4인실','Available'),(5,4,'미팅룸 A',4,'4인실','Available');
/*!40000 ALTER TABLE `room` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `room_maintenance`
--

DROP TABLE IF EXISTS `room_maintenance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `room_maintenance` (
  `maintenance_id` bigint NOT NULL AUTO_INCREMENT COMMENT '유지보수ID',
  `room_id` bigint NOT NULL COMMENT '(FK) 룸ID',
  `start_datetime` datetime NOT NULL COMMENT '예약 불가 시작 일시',
  `end_datetime` datetime NOT NULL COMMENT '예약 불가 종료 일시',
  `reason` varchar(255) DEFAULT NULL COMMENT '유지보수 사유',
  PRIMARY KEY (`maintenance_id`),
  KEY `room_id` (`room_id`),
  CONSTRAINT `room_maintenance_ibfk_1` FOREIGN KEY (`room_id`) REFERENCES `room` (`room_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='룸 예약 불가 일정';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `room_maintenance`
--

LOCK TABLES `room_maintenance` WRITE;
/*!40000 ALTER TABLE `room_maintenance` DISABLE KEYS */;
INSERT INTO `room_maintenance` VALUES (1,5,'2025-12-28 09:00:00','2025-12-28 23:00:00','난방기 긴급 수리');
/*!40000 ALTER TABLE `room_maintenance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `seat`
--

DROP TABLE IF EXISTS `seat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `seat` (
  `seat_id` bigint NOT NULL AUTO_INCREMENT COMMENT '좌석ID',
  `branch_id` bigint NOT NULL COMMENT '(FK) 지점ID',
  `seat_number` varchar(50) NOT NULL COMMENT '좌석 번호 (e.g., A-01)',
  `seat_type` varchar(100) NOT NULL COMMENT '''Open'', ''Partition'' 등',
  `status` varchar(50) NOT NULL DEFAULT 'Available' COMMENT '''Available'', ''InUse''',
  PRIMARY KEY (`seat_id`),
  KEY `branch_id` (`branch_id`),
  CONSTRAINT `seat_ibfk_1` FOREIGN KEY (`branch_id`) REFERENCES `branch` (`branch_id`)
) ENGINE=InnoDB AUTO_INCREMENT=146 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='개인 좌석 자산';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seat`
--

LOCK TABLES `seat` WRITE;
/*!40000 ALTER TABLE `seat` DISABLE KEYS */;
INSERT INTO `seat` VALUES (1,1,'P-01','Partition','Available'),(2,1,'P-02','Partition','Available'),(3,1,'P-03','Partition','Available'),(4,1,'P-04','Partition','Available'),(5,1,'P-05','Partition','Available'),(6,1,'P-06','Partition','Available'),(7,1,'P-07','Partition','Available'),(8,1,'P-08','Partition','Available'),(9,1,'P-09','Partition','Available'),(10,1,'P-10','Partition','Available'),(11,1,'P-11','Partition','Available'),(12,1,'P-12','Partition','Available'),(13,1,'P-13','Partition','Available'),(14,1,'P-14','Partition','Available'),(15,1,'P-15','Partition','Available'),(16,1,'O-01','Open','Available'),(17,1,'O-02','Open','Available'),(18,1,'O-03','Open','Available'),(19,1,'O-04','Open','Available'),(20,1,'O-05','Open','Available'),(21,1,'O-06','Open','Available'),(22,1,'O-07','Open','Available'),(23,1,'O-08','Open','Available'),(24,1,'O-09','Open','Available'),(25,1,'O-10','Open','Available'),(26,1,'O-11','Open','Available'),(27,1,'O-12','Open','Available'),(28,1,'O-13','Open','Available'),(29,1,'O-14','Open','Available'),(30,1,'O-15','Open','Available'),(31,2,'N-01','NewPartition','Available'),(32,2,'N-02','NewPartition','Available'),(33,2,'N-03','NewPartition','Available'),(34,2,'N-04','NewPartition','Available'),(35,2,'N-05','NewPartition','Available'),(36,2,'N-06','NewPartition','Available'),(37,2,'N-07','NewPartition','InUse'),(38,2,'N-08','NewPartition','Available'),(39,2,'N-09','NewPartition','Available'),(40,2,'N-10','NewPartition','Available'),(41,2,'N-11','NewPartition','Available'),(42,2,'N-12','NewPartition','Available'),(43,2,'N-13','NewPartition','Available'),(44,2,'N-14','NewPartition','Available'),(45,2,'C-01','SingleCubic','Available'),(46,2,'C-02','SingleCubic','Available'),(47,2,'C-03','SingleCubic','Available'),(48,2,'C-04','SingleCubic','Available'),(49,2,'C-05','SingleCubic','Available'),(50,2,'C-06','SingleCubic','Available'),(51,2,'C-07','SingleCubic','Available'),(52,2,'C-08','SingleCubic','Available'),(53,2,'C-09','SingleCubic','Available'),(54,2,'C-10','SingleCubic','Available'),(55,2,'C-11','SingleCubic','Available'),(56,2,'C-12','SingleCubic','Available'),(57,2,'C-13','SingleCubic','Available'),(58,2,'C-14','SingleCubic','Available'),(59,3,'S-01','SingleRoom','Available'),(60,3,'S-02','SingleRoom','Available'),(61,3,'S-03','SingleRoom','Available'),(62,3,'S-04','SingleRoom','Available'),(63,3,'S-05','SingleRoom','Available'),(64,3,'S-06','SingleRoom','Available'),(65,3,'S-07','SingleRoom','Available'),(66,3,'S-08','SingleRoom','Available'),(67,3,'S-09','SingleRoom','Available'),(68,3,'S-10','SingleRoom','Available'),(69,3,'S-11','SingleRoom','Available'),(70,3,'S-12','SingleRoom','Available'),(71,3,'S-13','SingleRoom','Available'),(72,3,'S-14','SingleRoom','Available'),(73,3,'S-15','SingleRoom','Available'),(74,3,'S-16','SingleRoom','Available'),(75,3,'S-17','SingleRoom','Available'),(76,3,'S-18','SingleRoom','Available'),(77,3,'S-19','SingleRoom','Available'),(78,3,'S-20','SingleRoom','Available'),(79,3,'N-01','NewPartition','Available'),(80,3,'N-02','NewPartition','Available'),(81,3,'N-03','NewPartition','Available'),(82,3,'N-04','NewPartition','Available'),(83,3,'N-05','NewPartition','Available'),(84,4,'P-01','Partition','Available'),(85,4,'P-02','Partition','Available'),(86,4,'P-03','Partition','Available'),(87,4,'P-04','Partition','Available'),(88,4,'P-05','Partition','Available'),(89,4,'P-06','Partition','Available'),(90,4,'P-07','Partition','Available'),(91,4,'P-08','Partition','Available'),(92,4,'P-09','Partition','Available'),(93,4,'P-10','Partition','Available'),(94,4,'P-11','Partition','Available'),(95,4,'P-12','Partition','Available'),(96,4,'P-13','Partition','Available'),(97,4,'P-14','Partition','Available'),(98,4,'P-15','Partition','Available'),(99,4,'P-16','Partition','Available'),(100,4,'P-17','Partition','Available'),(101,4,'P-18','Partition','Available'),(102,4,'P-19','Partition','Available'),(103,4,'P-20','Partition','Available'),(104,4,'P-21','Partition','Available'),(105,4,'P-22','Partition','Available'),(106,4,'P-23','Partition','Available'),(107,4,'P-24','Partition','Available'),(108,4,'P-25','Partition','Available'),(109,4,'O-01','Open','Available'),(110,4,'O-02','Open','Available'),(111,4,'O-03','Open','Available'),(112,4,'O-04','Open','Available'),(113,4,'O-05','Open','Available'),(114,5,'P-01','Partition','Available'),(115,5,'P-02','Partition','Available'),(116,5,'P-03','Partition','Available'),(117,5,'P-04','Partition','Available'),(118,5,'P-05','Partition','Available'),(119,5,'P-06','Partition','Available'),(120,5,'P-07','Partition','Available'),(121,5,'P-08','Partition','Available'),(122,5,'N-01','NewPartition','Available'),(123,5,'N-02','NewPartition','Available'),(124,5,'N-03','NewPartition','Available'),(125,5,'N-04','NewPartition','Available'),(126,5,'N-05','NewPartition','Available'),(127,5,'N-06','NewPartition','Available'),(128,5,'N-07','NewPartition','Available'),(129,5,'N-08','NewPartition','Available'),(130,5,'C-01','SingleCubic','Available'),(131,5,'C-02','SingleCubic','Available'),(132,5,'C-03','SingleCubic','Available'),(133,5,'C-04','SingleCubic','Available'),(134,5,'C-05','SingleCubic','Available'),(135,5,'C-06','SingleCubic','Available'),(136,5,'S-01','SingleRoom','Available'),(137,5,'S-02','SingleRoom','Available'),(138,5,'S-03','SingleRoom','Available'),(139,5,'S-04','SingleRoom','Available'),(140,5,'S-05','SingleRoom','Available'),(141,5,'S-06','SingleRoom','Available'),(142,2,'P-01','Partition','Available'),(143,2,'P-02','Partition','Available'),(144,2,'F-01','Free','InUse'),(145,2,'F-02','Free','InUse');
/*!40000 ALTER TABLE `seat` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `daily_reservation_status`
--

/*!50001 DROP VIEW IF EXISTS `daily_reservation_status`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `daily_reservation_status` AS select `r`.`start_datetime` AS `시작시간`,`m`.`member_name` AS `회원이름`,`s`.`seat_number` AS `좌석번호`,`r`.`status` AS `상태` from ((`reservation` `r` join `member` `m` on((`r`.`member_id` = `m`.`member_id`))) join `seat` `s` on((`r`.`seat_id` = `s`.`seat_id`))) where (`r`.`start_datetime` >= curdate()) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-11  1:06:19
