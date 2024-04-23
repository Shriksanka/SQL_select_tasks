
/*
 * So we need to connect 3 tables, because of "film_category" - is a bridge table,
 * than write where condition ( Animation, [2017, 2019] and rate > 1 ), alphabetical order.
 */
select title, rental_rate, release_year -- select the title
  from film -- from film table
 inner join film_category film_c on film.film_id = film_c.film_id -- join table (or just go to the film_category)
 inner join category on film_c.category_id = category.category_id -- join table (then we connect all three tables from film to category, so we have access to the where clausion)
 where category.name = 'Animation' -- we only need Animation category
   and film.release_year between 2017 and 2019 -- also we have requirment that must be released between 2017 and 2019
   and film.rental_rate > 1 -- and have rate more than 0
 order by film.title asc; -- and order aplhabetical.
 
 
 /*
  * So we need to make address and address2 - as one column rental_store_address.
  * In case of that we can have a NULL value, we will use COALESCE, to ensure, that 1 of adress will be displayed
  * Revenue will be calculated with aggregate function SUM. And joins will be from rental through inventory->store->address->payment(for revenue)
 */
/*
 * ----------------REWORKED----------------
 */
  select address.address || coalesce(', ' || address.address2, '') as rental_store_address, sum(payment.amount) as revenue
    from payment
   inner join rental on payment.rental_id = rental.rental_id 
   inner join inventory on rental.inventory_id = inventory.inventory_id 
   inner join store on inventory.store_id = store.store_id 
   inner join address on store.address_id = address.address_id 
   where payment.payment_date > '2017-03-31'
   group by address.address, address.address2 
   order by revenue desc;
  
  

 /*
  * Here we need only 3 tables: actor, film_actor and film.
  *	From actor we need first_name, last_name. And from film_actor we need count() the number of movies that actor took part in.
  * From film we only need release_year for condition (released after 2015)
*/
  select first_name, last_name, count(flm_actr.film_id) as number_of_movies -- first_name and last_name will be from actor, because we start from here, count(film_id) - so we will now number of films, we also can use: (first_name || ' ' || last_name as name)
    from actor -- so we will start from table actor 
   inner join film_actor flm_actr on actor.actor_id = flm_actr.actor_id -- then connecting to the film_actor table which is a bridge one
   inner join film on flm_actr.film_id = film.film_id -- then connectiong to the film table
   where film.release_year > 2015 -- here is condition for (released after 2015)
   group by first_name, last_name -- grouping by first_name and last_name because we are using aggregate function
   order by number_of_movies desc -- sorted in descending order
   limit 5; -- and limit it for Top-5 actors
   
 /*
  * In this query we will also need 3 tables: film, film_category and category.
  * From film we will need release_year, from film_category(because of the bridge table, we just need it for connection between film and category).
  * And in the category one, we will need Drama, Travel, Documentary values.
  * 
  * I will use three ways for solving it: 1) Using case 2) Using subquery 3) Using filter
 */
   -- 1) Using case
   select release_year, -- selecting release_year for next grouping and ordering
   sum(case when category.name = 'Drama' then 1 else 0 end) as number_of_drama_movies, -- we use case to find name of category only Drama, if it so we will count it as 1 if not the value be 0(so if we find film, and it is Drama we will count it like +1 if not +0)
   sum(case when category.name = 'Travel' then 1 else 0 end) as number_of_travel_movies, -- the same as for Drama, but for Travel one
   sum(case when category.name = 'Documentary' then 1 else 0 end) as number_of_documentary_movies -- the same as for Drama and Travel, but Documentary one
     from film -- we start from film table
    inner join film_category flm_ctgr on film.film_id = flm_ctgr.film_id -- connecting film_category
   	inner join category on flm_ctgr.category_id = category.category_id  -- connecting category
   	group by release_year -- grouping by release years
   	order by release_year desc; -- and sorting it with descending order (so we will start from near year)
   
   -- 2) Using subquery
   select release_year, -- selecting release_year for next ordering (w/o grouping, because in the main query we are not using aggregate functions)
   (select count(film.film_id) -- here we start counting in subquery films
      from film -- start from film
     inner join film_category flm_ctgr on film.film_id = flm_ctgr.film_id -- connecting to the film_category
     inner join category on flm_ctgr.category_id = category.category_id -- connecting to the category
      where category.name = 'Drama' and film.release_year = film_years.release_year) as number_of_drama_movies, -- so here we searching only for Drama and for the year which one will be responded by the additional query in from (of the main table - because in the respond will be distinct values, and for all films, that's mean that we will have all years in which ones were released some of films)
   (select count(film.film_id) -- The same for the second subquery but for Travel one
      from film 
     inner join film_category flm_ctgr on film.film_id = flm_ctgr.film_id
     inner join category on flm_ctgr.category_id = category.category_id 
      where category.name = 'Travel' and film.release_year = film_years.release_year) as number_of_travel_movies,
   (select count(film.film_id) -- The same for the third subquery but for Documentary one
      from film 
     inner join film_category flm_ctgr on film.film_id = flm_ctgr.film_id
     inner join category on flm_ctgr.category_id = category.category_id 
      where category.name = 'Documentary' and film.release_year = film_years.release_year) as number_of_documentary_movies
     from (select distinct release_year from film) film_years
    order by release_year desc; -- We are not needing to use group (and we can't :) ), so just sorted it with descending order
    -- why we are not needed it grouping it? Because of "from" clause we will have all years (distinct ones)
    
   -- 3) Using filter
   select release_year,
   count(*) filter (where category.name = 'Drama') as number_of_drama_movies, -- here we are using filter, to separate all films, that are not in Drama category, so we will count only Drama's one
   count(*) filter (where category.name = 'Travel') as number_of_travel_movies, -- here we are using filter, to separate all films, that are not in Drama category, so we will count only Travel's one
   count(*) filter (where category.name = 'Documentary') as number_of_documentary_movies -- here we are using filter, to separate all films, that are not in Drama category, so we will count only Documentary's one
	 from film -- start from film table
	inner join film_category flm_ctgr on film.film_id = flm_ctgr.film_id -- connecting to the film_category table
	inner join category on flm_ctgr.category_id = category.category_id -- connecting to the category table
	group by release_year -- grouping (because we are using aggregate functions)
	order by release_year desc; -- sorting it in descending order
	
	
/*
 * If I understand it right, we will focus only on "Who were the top revenue-generating staff members in 2017? They should be rewarded with a bonus for their performance. Please indicate which store the employee worked in."
 * Because they have been already connected to the new store - and that's their last store.
 * So we need information about staff member, who made top total revenue in 2017. We will take it from staff table.
 * Then we need to focus on condition about 2017 year. We can find this information from payment table -> then we can end with rental table ( because it is our "orders" table )
 */
	select staff.first_name || ' ' || staff.last_name as staff_member, sum(payment.amount) as total_revenue, staff.store_id -- Here we selecting all information that we need all information for analysis
	  from payment -- start from payment table, because the question was about rental, so for easier work we will start from here
	 inner join rental on payment.rental_id = rental.rental_id  -- connecting to the rental
	 inner join staff on rental.staff_id = staff.staff_id  -- connecting to the staff
	 where extract(year from payment.payment_date) = 2017 -- indicate that we are searching only for 2017 year
	 group by staff_member, staff.store_id -- grouping by staff_member and store_id
	 order by total_revenue desc -- ordering in descending way for top-3 members
	 limit 3; -- limit it to the top-3 members
/* As we can see, Hanna Carry is the top competitor because she earned $79736.45 for 2017, which is 49% more than the top 2 who earned $40537.94.
 * Interestingly, if you add up the top 2 and top 3, the total earnings are slightly more than Hanna Carry alone. So it's a very simple task for us - the bonus should be rewarded to Hanna Carry.
 */
	 
	 
/*
 * We need to use aggregate function to sum up quantity of RENTAL films. Also we need use CASE to use 'Motion Picture Association film raiting system'.
 * For joins we will use rental table (as first one) - because question about rentals, then inventory table for connection to the film table ( for raitings ).
 */
	 select film.title, film.rating, count(rental.rental_id) as quantity_of_rental,
	 case
	 	when film.rating = 'G' then 'General audiences – All ages admitted'
	 	when film.rating = 'PG' then 'Parental guidance suggested – Some material may not be suitable for children'
	 	when film.rating = 'PG-13' then 'Parents strongly cautioned – Some material may be inappropriate for children under 13'
	 	when film.rating = 'R' then 'Restricted – Under 17 requires accompanying parent or adult guardian'
	 	when film.rating = 'NC-17' then 'Adults only – No one 17 and under admitted'
	 end as audience_age
	   from rental
	  inner join inventory inv on rental.inventory_id = inv.inventory_id 
	  inner join film on inv.film_id = film.film_id 
	  group by film.title, film.rating 
	  order by quantity_of_rental desc
	  limit 5;
	 
/* So, the "BUCKET BROTHERHOOD", "ROCKETEER MOTHER", "FORWARD TEMPLE", "SCALAWAG DUCK", "GRIT CLOCKWORK" - the 5 movies which were renterd more than others (>60 times) 
 * For example, average quantity of rentals is ~33. You can find this information under this comment.
 */
	 select avg(rental_count) as average_rentals_per_film
	   from (select film.film_id, count(rental.rental_id) as rental_count
	   		   from film
	   		  inner join inventory inv on film.film_id = inv.film_id
	   		  inner join rental on inv.inventory_id = rental.inventory_id
	   		  group by film.film_id) as qunatities_rental;
	 
	 
/* 
 * V1: gap between the latest release_year and current year per each actor;
 * Here we need to extract year from the current date and minus from the latest RELEASED Year of film where was this actor.
 */
	 select first_name || ' ' || last_name as actor_name, max(film.release_year) as year_of_the_latest_film,
	 		(extract(year from current_date) - max(film.release_year)) as gap_in_years -- having gaps
	   from actor
	  inner join film_actor on actor.actor_id = film_actor.actor_id 
	  inner join film on film_actor.film_id = film.film_id 
	  group by actor_name
	  order by gap_in_years desc; -- sorted in descending order.
-- For the V1 we have -> that Humphrey Garland has 9 years w/o acting in the films. For example top 2-4 have 8 years.
	  
/* V2: gaps between sequential films per each actor;
 * This is more complicated one, because we must not only calculate the gaps, but make a condition that in the gaps between two films wasn't any others films. 
 * So we need to take 2 films, compare them and calculate the gap, next we must to ensure, that this 2 films don't have any others films between the years of released. 
 */
	 select first_name || ' ' || last_name as actor_name, max(second_film.release_year - first_film.release_year) as max_gap_in_years, first_film.release_year, second_film.release_year -- so, here we selecting actor_name, max gap in years between films and their release_years
	   from actor -- start from table actor
	  inner join film_actor film_actor_one on actor.actor_id = film_actor_one.actor_id -- because of that we need 2 dates for one actor, we will use double join, I mean that we will have 2 times joins of film_actor and film
	  inner join film first_film on film_actor_one.film_id = first_film.film_id 
	  inner join film_actor film_actor_two on actor.actor_id = film_actor_two.actor_id 
	  inner join film second_film on film_actor_two.film_id = second_film.film_id and second_film.release_year > first_film.release_year -- when we already have first film release year, we can write to this join also a condtion that second film must be released later
	  where not exists (select 1 -- here the interesting one. Because of that we will have a lot of (first_year, second_year) we want find only ones, which have no film between this years, so we need only 1 attribute, if it is so -> we won't use this gap
	  					  from film_actor film_actor_three -- third time adding film actor and film table, only for conditional task
	  					  join film third_film on film_actor_three.film_id = third_film.film_id
	  					 where film_actor_three.actor_id = actor.actor_id and third_film.release_year > first_film.release_year AND third_film.release_year < second_film.release_year) -- I'm not sure why I had problem here with using between statment (please give me some info about it)
	  group by actor_name, first_film.release_year, second_film.release_year 
	  order by max_gap_in_years desc; -- sorted in descending order
-- Here we have 2 people who has 9 years gap between films: Jayne Neeson and Minnie Kilmer
	  
/* V3: gap between the release of their first and last film;
 * This is not hard as V2, we only need info about max(release_year) and min one. And calculate the difference between them.
 */
	  select first_name || ' ' || last_name as actor_name, min(film.release_year) as first_film, max(film.release_year) as last_film, (max(film.release_year) - min(film.release_year)) as gap_in_years
	    from actor
	   inner join film_actor on actor.actor_id = film_actor.actor_id 
	   inner join film on film_actor.film_id = film.film_id 
	   group by actor_name
	   order by gap_in_years desc;
-- Here we have more interesting situation: 37 actors who has 30 years gap in their the first and the last film.