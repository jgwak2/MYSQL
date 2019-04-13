use sakila;
-- 1a.Display the first and last names of all actors from the table actor.
Select first_name, last_name
	from actor;
	-- select count(*) from actor;
	-- select *
	--   from actor 
	--   limit 10;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
select concat(first_name, ' ', last_name) as Actor_Name from actor;
		-- ALTER TABLE `sakila`.`actor` 
		-- CHANGE COLUMN `actor_name` `actor_name` VARCHAR(45);

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."  What is one query would you use to obtain this information?
select actor_id, first_name, last_name
	from actor
	where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
select * from actor 
	where last_name like '%Gen%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select last_name, first_name
	from actor
	where last_name like '%LI%'

-- 2d. Using IN, display the country_id and country columns of the following countries: 
select country_id, country
  from sakila.country
  where country in ('Afghanistan', 'Bangladesh', 'China');
  
--  3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
alter table actor 
	add (actor_description blob);

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
Alter table actor
	drop column actor_description;
    
-- 4a. List the last names of actors, as well as how many actors have that last name.
select last_name , count(*)  as count
	from actor
    group by last_name;

	-- Select last_name
	-- 	(Select count(*)
	-- 		from actor
	-- 		where name = D.name)
	-- 	as count
	-- from actor as D
-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
select last_name , count(*)  c
	from actor
    group by last_name
    having c >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
update actor
	set first_name = upper('harpo')
    where first_name = 'Groucho';
select * from actor
	where last_name = 'WILLIAMS';
    
    
-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
update actor
	set first_name = upper('groucho')
    where first_name = 'harpo';
select * from actor
	where last_name = 'williams';
    
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
create database new_schema; -- ??

-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html



-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
select S.first_name, S.last_name, A.address
	from staff S, address A
	where S.address_id = A.address_id;

	-- select count(*) from address;

		SELECT s.first_name, s.last_name, a.address
			FROM staff s
			INNER JOIN address a
			ON (s.address_id = a.address_id);
-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select staff_id, sum(amount)
	from payment
    group by staff_id;
    having YEAR(payment_date) = 2005 AND Month(payment_date) = 8
    
select staff_id, amount, payment_date
	from payment
	WHERE YEAR(payment_date) = 2005 AND Month(payment_date) = 8
    ;

SELECT p.staff_id, s.staff_id, sum(p.amount)
	FROM payment p
    inner Join staff s
    on (p.staff_id = s.staff_id)
	WHERE YEAR(payment_date) = 2005 AND Month(payment_date) = 8;



-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
select f.title, f.film_id, fa.film_id, fa.actor_id
	from film_actor fa 
    inner join film f
    on (fa.film_id = f.film_id)
    
    
-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
select f.film_id, f.title, i.film_id
	from film f
    inner join inventory i
    on (f.film_id = i.film_id)

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
select c.first_name, c.last_name, p.amount
	from customer c 
    inner join payment p
    on  c.customer_id = p.customer_id
    
	-- alphabetically



-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title 
  FROM FILM F
 WHERE ((F.title like 'K%')  OR
	   (F.title like 'Q%')  AND
	   (F.language_id IN  ( Select language_id 
							from  language L
                            where L.name = 'English' )))
	
-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
select  A.first_name, A.last_name 
  from  film_actor FA
       ,actor       A
where  FA.film_id = (SELECT FILM_ID FROM FILM F WHERE F.title = 'Alone Trip')
  and  FA.actor_id = A.actor_id

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT C.first_name, C.last_name, C.email
  FROM CUSTOMER C
 WHERE address_id in (select  A.address_id 
                        from  ADDRESS A
                             ,CITY    CI
                             ,COUNTRY CN
                       where  A.city_id     = CI.city_id
                         AND  CI.country_id = CN.country_id
                         AND  CN.country = 'Canada')

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT F.title, F.description
  from FILM F
 WHERE F.film_id in 
                (select  FC.film_id 
                   from  film_category FC
                        ,Category      C
				  where  FC.category_id = C.category_id
                    and  C.name = 'Family'
                )

-- 7e. Display the most frequently rented movies in descending order.
select  I.film_id, F.title,  count(*) as count_rented
 from   rental    R 
       ,inventory I 
       ,Film      F
where   R.inventory_id = I.inventory_id
  and   I.film_id      = F.film_id
Group by I.film_id, F.title
order by count_rented Desc

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT    C.store_id, Sum(P.amount) as Total_store
    From  Payment  P
         ,Customer C
         
	where  P.customer_id = C.customer_id 
    Group by C.store_id

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT S.store_id, CI.city, CN.country
 FROM  STORE   S
      ,ADDRESS A
      ,CITY    CI
      ,COUNTRY CN
 
 where S.address_id  = A.address_id
   and A.city_id     = CI.city_id
   and CI.country_id = CN.country_id
;
-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT C.name as Genre, sum(P.AMOUNT) as Gross_revenue
  FROM   PAYMENT  P
		,RENTAL   R
        ,inventory I
        ,FILM_CATEGORY FC
        ,Category  C
WHERE    P.rental_id = R.rental_id
  AND    R.inventory_id = I.inventory_id
  AND    I.film_id      = FC.film_id
  AND    FC.category_id = C.category_id
GROUP BY C.name
ORDER BY 2 DESC
LIMIT  5 

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Gross_revenue_genre as 
	(SELECT C.name as Genre, sum(P.AMOUNT) as Gross_revenue
	  FROM   PAYMENT  P
			,RENTAL   R
			,inventory I
			,FILM_CATEGORY FC
			,Category  C
	WHERE    P.rental_id = R.rental_id
	  AND    R.inventory_id = I.inventory_id
	  AND    I.film_id      = FC.film_id
	  AND    FC.category_id = C.category_id
	GROUP BY C.name
	ORDER BY 2 DESC
	LIMIT  5 )
;

-- 8b. How would you display the view that you created in 8a?
SHOW CREATE VIEW Gross_revenue_genre;
-- Use below query to display all rows from the view. 
SELECT * FROM Gross_revenue_genre ;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Gross_revenue_genre;



