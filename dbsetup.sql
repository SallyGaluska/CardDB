mysql -u root -p < creates_and_alters

LOAD data local infile '/home/student/Documents/AllCardsIncludingUnsets' 
IGNORE INTO TABLE MagicCards.cards 
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
(card_name);

LOAD data local infile '/home/student/Documents/allsets' 
IGNORE INTO TABLE MagicCards.sets 
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
(set_code, set_name);

LOAD data local infile '/home/student/Documents/prices_of_mycollection.csv' 
IGNORE INTO TABLE my_collection_temp 
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"';

INSERT IGNORE INTO card_sets(card_id, set_id, price)
SELECT card_id, set_id, prices
FROM my_collection_temp
JOIN cards ON my_collection_temp.name=cards.card_name
JOIN sets on my_collection_temp.setcode=sets.set_code;

SELECT card_name, set_name, price
FROM card_sets
JOIN cards ON card_sets.card_id=cards.card_id
JOIN sets ON card_sets.set_id=sets.set_id
WHERE card_name="Solemn Simulacrum";

