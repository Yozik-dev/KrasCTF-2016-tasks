-- --------------------------------------------------------
-- Хост:                         127.0.0.1
-- Версия сервера:               10.1.10-MariaDB - mariadb.org binary distribution
-- ОС Сервера:                   Win32
-- HeidiSQL Версия:              9.3.0.4984
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Дамп структуры для таблица krasctf.shadowd_sess
CREATE TABLE IF NOT EXISTS `shadowd_sess` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `sess` varchar(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `Индекс 2` (`sess`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы krasctf.shadowd_sess: ~3 rows (приблизительно)
/*!40000 ALTER TABLE `shadowd_sess` DISABLE KEYS */;
INSERT INTO `shadowd_sess` (`id`, `sess`) VALUES
	(4, '73jZrMPKdLsbev2baiHxTmggpZV8UKHdZMjIK8eesp9RVu_7'),
	(6, 'FInNQfAwjzvJKgM2qUwfSCzdSEaGyr4yzL729bdHbdGSZQjd'),
	(5, 'Pu8yTbfczQNPSrTlT1E1rCIu9ljGfOu8YB_Iwf-xJsnJhiKh');
/*!40000 ALTER TABLE `shadowd_sess` ENABLE KEYS */;


-- Дамп структуры для таблица krasctf.shadowd_ua
CREATE TABLE IF NOT EXISTS `shadowd_ua` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `session_id` int(10) unsigned NOT NULL,
  `ua` text NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_shadowd_ua_shadowd_sess` (`session_id`),
  CONSTRAINT `FK_shadowd_ua_shadowd_sess` FOREIGN KEY (`session_id`) REFERENCES `shadowd_sess` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8;

-- Дамп данных таблицы krasctf.shadowd_ua: ~4 rows (приблизительно)
/*!40000 ALTER TABLE `shadowd_ua` DISABLE KEYS */;
INSERT INTO `shadowd_ua` (`id`, `session_id`, `ua`) VALUES
	(39, 4, 'Flag#1a9e5554de21653f000XXX'),
	(40, 5, 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36'),
	(43, 5, 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36'),
	(46, 6, 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36');
/*!40000 ALTER TABLE `shadowd_ua` ENABLE KEYS */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
