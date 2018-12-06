/*this query asks about all cards named "Sol Ring" in my collection. How many do I have, from which sets, and how much do they cost based on their set?*/
SELECT card_name, set_code, quantity, price FROM my_collection
JOIN card_sets AS cs ON my_collection.card_set_id=cs.card_set_id
JOIN cards ON cards.card_id=cs.card_id
JOIN sets ON sets.set_id=cs.set_id
WHERE card_name="Sol Ring";


/*These two queries test the functionality of the moveReducedQuantityToTraded. The first one reduces the quantity from 4 to 2. The trigger triggers, the if statement evaulates to true, and the trigger performs an insert. The second one still triggers the trigger, but the if statment evaluates to false, so it doesn't do anything.*/
update my_collection quantity=2 where card_set_id=31;
update my_collection quantity=3 where card_set_id=30;
