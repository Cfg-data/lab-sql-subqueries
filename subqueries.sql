USE sakila

-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT COUNT(i.inventory_id) AS num_copies
FROM inventory i
JOIN film f ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT title
FROM film
WHERE length > (SELECT AVG(length) FROM film);

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
    SELECT actor_id
    FROM film_actor
    JOIN film f ON film_actor.film_id = f.film_id
    WHERE f.title = 'Alone Trip'
);

-- Bonus:

-- 4. Identify all movies categorized as family films.
SELECT f.title
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
WHERE c.name = 'Family';

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins.

-- Using a subquery:
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
    SELECT address_id
    FROM address
    JOIN city ON address.city_id = city.city_id
    JOIN country ON city.country_id = country.country_id
    WHERE country.country = 'Canada'
);

-- Using a join:
SELECT c.first_name, c.last_name, c.email
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

-- 6. Determine which films were starred by the most prolific actor in the Sakila database.
-- First, find the most prolific actor:
SELECT actor_id
FROM film_actor
GROUP BY actor_id
ORDER BY COUNT(film_id) DESC
LIMIT 1;

-- Now use the most prolific actor's actor_id to find the films they starred in:
SELECT f.title
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
WHERE fa.actor_id = (SELECT actor_id
                      FROM film_actor
                      GROUP BY actor_id
                      ORDER BY COUNT(film_id) DESC
                      LIMIT 1);

-- 7. Find the films rented by the most profitable customer in the Sakila database.
-- First, find the most profitable customer:
SELECT customer_id
FROM payment
GROUP BY customer_id
ORDER BY SUM(amount) DESC
LIMIT 1;

-- Now use the most profitable customer's customer_id to find the films they rented:
SELECT f.title
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE r.customer_id = (
    SELECT customer_id
    FROM payment
    GROUP BY customer_id
    ORDER BY SUM(amount) DESC
    LIMIT 1
);

-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
SELECT customer_id, SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING total_amount_spent > (
    SELECT AVG(total_amount_spent)
    FROM (
        SELECT customer_id, SUM(amount) AS total_amount_spent
        FROM payment
        GROUP BY customer_id
    ) AS subquery
);
