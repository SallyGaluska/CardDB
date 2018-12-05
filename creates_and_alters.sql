DROP DATABASE IF EXISTS MagicCards;
CREATE DATABASE MagicCards CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
use MagicCards;

DROP TABLE IF EXISTS my_collection_temp;
CREATE TABLE my_collection_temp(
name varchar(141),
set_code varchar(4),
quantity int unsigned,
price decimal(10,2)
)engine = InnoDB DEFAULT CHARSET utf8mb4 collate=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS cards;
CREATE TABLE cards(
card_id int UNSIGNED not null primary key auto_increment,
card_name varchar(141)
)engine = InnoDB DEFAULT CHARSET utf8mb4 collate=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS sets;
CREATE TABLE sets(
set_id int UNSIGNED not null primary key auto_increment,
set_code varchar(7),
set_name varchar(50)
)engine = InnoDB Default Charset utf8mb4 collate=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS card_sets;
CREATE TABLE card_sets(
card_set_id INT UNSIGNED not null primary key auto_increment,
card_id INT UNSIGNED,
set_id INT UNSIGNED,
price decimal(10,2),
date_last_updated DATETIME
)engine = InnoDB DEFAULT CHARSET utf8mb4 collate=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS my_collection;
CREATE TABLE my_collection(
my_collection_id int UNSIGNED not null primary key auto_increment,
card_set_id int unsigned,
quantity INT UNSIGNED
)engine = InnoDB DEFAULT CHARSET utf8mb4 collate=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS my_collection_price_over_time;
CREATE TABLE my_collection_price_over_time(
my_collection_over_time_id int UNSIGNED not null primary key auto_increment,
sum_snapshot DECIMAL(10,2),
sum_snapshot_date DATETIME
)engine = InnoDB DEFAULT CHARSET utf8mb4 collate=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS cards_traded_away;
CREATE TABLE cards_traded_away(
card_traded_away_id int UNSIGNED not null primary key auto_increment,
card_set_id int unsigned,
quantity INT UNSIGNED
)engine = InnoDB DEFAULT CHARSET utf8mb4 collate=utf8mb4_unicode_ci;

DROP TABLE IF EXISTS traded_away_price_over_time;
CREATE TABLE traded_away_price_over_time(
traded_away_over_time_id int UNSIGNED not null primary key auto_increment,
sum_snapshot DECIMAL(10,2),
sum_snapshot_date DATETIME
)engine = InnoDB DEFAULT CHARSET utf8mb4 collate=utf8mb4_unicode_ci;

ALTER TABLE `card_sets` ADD FOREIGN KEY (card_id) REFERENCES `cards` (`card_id`);
ALTER TABLE `card_sets` ADD FOREIGN KEY (set_id) REFERENCES `sets` (`set_id`);
ALTER TABLE `my_collection` ADD FOREIGN KEY (card_set_id) REFERENCES `card_sets` (`card_set_id`);
ALTER TABLE `cards_traded_away` ADD FOREIGN KEY (card_set_id) REFERENCES `card_sets` (`card_set_id`);
