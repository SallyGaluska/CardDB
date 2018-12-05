/*setting up so that this can run and recreate the database in its entirety, even if the database already exists. This was very useful for testing. Whenever I screwed anything up i could just reset everything.*/
DROP DATABASE IF EXISTS MagicCards;
CREATE DATABASE MagicCards CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
use MagicCards;

/*creates*/
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

/*foreign keys*/

ALTER TABLE `card_sets` ADD FOREIGN KEY (card_id) REFERENCES `cards` (`card_id`);
ALTER TABLE `card_sets` ADD FOREIGN KEY (set_id) REFERENCES `sets` (`set_id`);
ALTER TABLE `my_collection` ADD FOREIGN KEY (card_set_id) REFERENCES `card_sets` (`card_set_id`);
ALTER TABLE `cards_traded_away` ADD FOREIGN KEY (card_set_id) REFERENCES `card_sets` (`card_set_id`);

/*loading in the data*/

LOAD data local infile '/home/student/Documents/CardDB/AllCardsIncludingUnsets'
IGNORE INTO TABLE MagicCards.cards
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
(card_name);

LOAD data local infile '/home/student/Documents/CardDB/allsets'
IGNORE INTO TABLE MagicCards.sets
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
(set_code, set_name);

LOAD data local infile '/home/student/Documents/CardDB/prices_of_my_collection.csv'
IGNORE INTO TABLE my_collection_temp
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"';

/*generating card_sets and my_collection based on my_collection_temp*/

INSERT INTO card_sets(card_id, set_id, price, date_last_updated)
SELECT DISTINCT card_id, set_id, price, CURRENT_TIMESTAMP
FROM my_collection_temp
JOIN cards ON my_collection_temp.name=cards.card_name
JOIN sets on my_collection_temp.set_code=sets.set_code;

INSERT IGNORE INTO my_collection(card_set_id, quantity)
SELECT DISTINCT cs.card_set_id, mct.quantity
FROM my_collection_temp as mct
JOIN cards on cards.card_name=mct.name
JOIN sets on sets.set_code=mct.set_code
JOIN card_sets as cs on cs.card_id=cards.card_id and cs.set_id=sets.set_id;

/*trigger. just one. knock points off if you have to. I could make my database make less sense and be less intuitive to add another trigger and get full points but I don't feel like being a bad programmer today.*/
delimiter $
CREATE TRIGGER moveDeletedToTraded BEFORE DELETE ON my_collection
FOR EACH ROW BEGIN
INSERT INTO cards_traded_away(card_set_id, quantity)
values(OLD.card_set_id, OLD.quantity);
END$
delimiter ;

/*deleting a record from my_collection so that the "cardstradedaway" table has data*/
DELETE FROM my_collection where my_collection.card_set_id=
(SELECT mccsi from
(SELECT mc.card_set_id as mccsi FROM my_collection as mc
JOIN card_sets as cs ON mc.card_set_id=cs.card_set_id
JOIN cards on cards.card_id=cs.card_id
JOIN sets on sets.set_id=cs.set_id
WHERE card_name="Sol Ring" and set_code="3ed")as thisisonlyheretomakesqlhappy);

/*please don't think too much about the number that gets inserted into my_collection_price_over_time whenever this event runs. I promise I haven't actually spent that much on pieces of cardboard...*/
delimiter $
CREATE EVENT getSums
ON SCHEDULE EVERY 1 WEEK
  DO BEGIN
  insert into my_collection_price_over_time(sum_snapshot, sum_snapshot_date)
  select sum(price*quantity) as sum_snapshot, CURRENT_TIMESTAMP from my_collection as mc
  JOIN card_sets AS cs ON cs.card_set_id=mc.card_set_id;
  insert into traded_away_price_over_time(sum_snapshot, sum_snapshot_date)
  select sum(price*quantity) as sum_snapshot, CURRENT_TIMESTAMP from cards_traded_away as cta
  JOIN card_sets AS cs ON cs.card_set_id=cta.card_set_id;
END $
delimiter ;

/*view that displays your collection in a way that humans can understand. ...well, some humans can, anyway.*/
create Algorithm=temptable view your_collection AS
SELECT card_name, set_code, quantity, price FROM my_collection
JOIN card_sets AS cs ON my_collection.card_set_id=cs.card_set_id
JOIN cards ON cards.card_id=cs.card_id
JOIN sets ON sets.set_id=cs.set_id;

/*similar view for cards_traded_away. Selecting from these views simplifies things for the user while perserving normalization of the database.*/
create Algorithm=temptable view your_cards_traded_away AS
SELECT card_name, set_code, quantity, price FROM cards_traded_away as cta
JOIN card_sets AS cs ON cta.card_set_id=cs.card_set_id
JOIN cards ON cards.card_id=cs.card_id
JOIN sets ON sets.set_id=cs.set_id;

/*making users*/
DROP USER IF EXISTS "readonly"@"localhost";
CREATE USER "readonly"@"localhost" identified by "Readonlypass 1";
GRANT select on MagicCards.* to "readonly"@"localhost";

DROP USER IF EXISTS "admin"@"localhost";
CREATE USER "admin"@"localhost" identified by "Adminpass 1";
GRANT create, drop, insert, delete, update on MagicCards.* to "admin"@"localhost";

DROP USER IF EXISTS "viewsonly"@"localhost";
CREATE USER "viewsonly"@"localhost" identified by "Viewsonlypass 1";
GRANT select on MagicCards.your_collection to "viewsonly"@"localhost";
GRANT select on MagicCards.your_cards_traded_away to "viewsonly"@"localhost";

/*Procedures and Functions*/

/*Deleting from my_collection activates a trigger which moves the card info to "Cards_Traded_Away"*/
delimiter $
CREATE PROCEDURE deleteFromCollection(card_name_to_delete varchar(141), set_code_to_delete varchar(7))
BEGIN
DELETE FROM my_collection where my_collection.card_set_id=
(SELECT mccsi from
(SELECT mc.card_set_id as mccsi FROM my_collection as mc
JOIN card_sets as cs ON mc.card_set_id=cs.card_set_id
JOIN cards on cards.card_id=cs.card_id
JOIN sets on sets.set_id=cs.set_id
WHERE card_name=card_name_to_delete and set_code=set_code_to_delete)as thisisonlyheretomakesqlhappy);
END $
delimiter ;
/*Unfortunately, this query has to be kind of roundabout to get around some weird restrictions that sql has. The better way of doing this would probably be using your php interface to just run the nested select and feed the data into the delete.*/

delimiter $
CREATE PROCEDURE getPrice(search_card_name VARCHAR(141), search_set_code VARCHAR(7))
BEGIN
SELECT price FROM my_collection
JOIN card_sets AS cs ON my_collection.card_set_id=cs.card_set_id
JOIN cards ON cards.card_id=cs.card_id
JOIN sets ON sets.set_id=cs.set_id
WHERE card_name=search_card_name and set_code=search_set_code;
END$
delimiter ;

delimiter $
CREATE FUNCTION getMySum()
RETURNS FLOAT
READS SQL DATA
BEGIN
set @results=0;
select sum(price*quantity) INTO @results from my_collection as mc
JOIN card_sets AS cs ON cs.card_set_id=mc.card_set_id;
return @results;
END $
delimiter ;

delimiter $
CREATE FUNCTION getPrice(search_card_name VARCHAR(141), search_set_code VARCHAR(7))
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
set @result=0;
SELECT price into @result FROM my_collection
JOIN card_sets AS cs ON my_collection.card_set_id=cs.card_set_id
JOIN cards ON cards.card_id=cs.card_id
JOIN sets ON sets.set_id=cs.set_id
WHERE card_name=search_card_name and set_code=search_set_code;
return @result;
END$
delimiter ;
