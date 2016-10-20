CREATE TABLE IF NOT EXISTS `table_1_1` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) COLLATE utf8_bin NOT NULL,
  `description` varchar(256) COLLATE utf8_bin DEFAULT NULL,
  `price` float NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

INSERT INTO `table_1_1` (`id`, `name`, `description`, `price`, `created_at`, `updated_at`) VALUES
	(1, 'Атомный генератор', NULL, 500, '2016-07-01 16:56:22', '2016-07-01 18:38:54'),
	(2, 'Андронный коллайдер', NULL, 40, '2016-07-01 16:56:38', '2016-07-01 18:38:52'),
	(3, 'Генератор Тесла', NULL, 1, '2016-07-01 16:56:49', '2016-07-01 18:38:57'),
	(4, 'Протонная бомба', NULL, 8, '2016-07-01 16:57:00', '2016-07-01 18:39:01'),
	(5, 'Гидрополяризатор', NULL, 45, '2016-07-01 16:57:11', '2016-07-01 18:39:00');