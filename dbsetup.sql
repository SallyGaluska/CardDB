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

INSERT INTO card_sets(card_id, set_id, price)
SELECT DISTINCT card_id, set_id, price
FROM my_collection_temp
JOIN cards ON my_collection_temp.name=cards.card_name
JOIN sets on my_collection_temp.set_code=sets.set_code;

INSERT IGNORE INTO my_collection(card_set_id, quantity)
SELECT DISTINCT card_set_id, quantity
FROM card_sets
JOIN cards on cards.card_id=card_sets.card_id
JOIN sets on sets.set_id=card_sets.set_id
JOIN my_collection_temp on my_collection_temp.name=cards.card_name;

