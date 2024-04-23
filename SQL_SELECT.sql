/*
 * We must select category_name which is category table. Then we must sum up the total income of this categories which is rental table.
 * For that we must add such tables as inventory(for film, because only film table has a category_id - that will be useful for us).
 * Also we need connect film table for that.
 * The hard one is the condition that it must be in USA, for that we need country table, then city table, then address table.
 * Continue with customer table and go to the payment table, then we will end with the rental table.
 * 
 * It is easier, when we look on our diagram: we will start from category ( to get category name ) ->
 * then goes to the film_category to go to the film, because only in this way we can solve it ( we must now total income, but it is only in rental table ) ->
 * go to the inventory table, then go to the rental. Here we will start our condition trip: ->
 * go to the payment, for customer date -> go to the customer table. Here we have access to the address ->
 * why address? Because we know that we need USA country and we can extract it only with country table, which is connected to the city table, and then to the address one.
 */
	select ctgr.name as category_name, sum(p.amount) as total_income
	  from category ctgr
	 inner join film_category f_ctgr on ctgr.category_id = f_ctgr.category_id 
	 inner join film on f_ctgr.film_id = film.film_id 
	 inner join inventory inv on film.film_id = inv.film_id 
	 inner join rental on inv.inventory_id = rental.inventory_id 
	 inner join payment p on rental.rental_id = p.rental_id 
	 inner join customer cstmr on rental.customer_id = cstmr.customer_id 
	 inner join address addr on cstmr.address_id = addr.address_id 
	 inner join city on addr.city_id = city.city_id 
	 inner join country on city.country_id = country.country_id 
	 where country.country = 'United States'
	 group by category_name
	 order by total_income desc
	 limit 3;
-- Answer: top-1: Documentary with 1070,01$, top-2: Sports with 1069,45$, top-3: Drama with 1003,29$
	
/*
 * For this question we need tables: customer, for data of customer, then film and film category for film title and the category of horror.
 * We also need payment table for the total amount of money.
 * 
 * Here we will start from customer table, than go to the rental table to have acess to the inventory and payment table ->
 * than we will go to the film ( for titles ) and through the film_category to the category.
 */
	select cstmr.first_name || ' ' || cstmr.last_name as customer_name,
	       string_agg(film.title, ', ') as rented_horror_films, sum(p.amount) as total_amount_for_films
	  from customer cstmr
	 inner join rental on cstmr.customer_id = rental.customer_id 
	 inner join inventory inv on rental.inventory_id = inv.inventory_id 
	 inner join film on inv.film_id = film.film_id 
	 inner join film_category f_ctgr on film.film_id = f_ctgr.film_id 
	 inner join category ctgr on f_ctgr.category_id = ctgr.category_id 
	 inner join payment p on rental.rental_id = p.rental_id
	 where ctgr.name = 'Horror'
	 group by customer_name
	 order by total_amount_for_films desc;

