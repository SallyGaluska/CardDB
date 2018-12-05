/*this query asks about all cards named "sol ring" in my collection. How many do I have, from which sets, and how much do they cost based on their set?*/
SELECT card_name, set_code, quantity, price FROM my_collection
JOIN card_sets AS cs ON my_collection.card_set_id=cs.card_set_id
JOIN cards ON cards.card_id=cs.card_id
JOIN sets ON sets.set_id=cs.set_id
WHERE card_name="Sol Ring";

