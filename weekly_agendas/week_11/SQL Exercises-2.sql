USE SampleRetail;

---- 1. Find the store that generated the highest revenue in the 4th, 5th, and 6th months of 2019.----

--looking sale.orders table for order_id, order_date, store_id
SELECT * 
FROM sale.orders;


--looking sale.order_item table for order_id, product_id, quantity, list_price, discount
SELECT * 
FROM sale.order_item;


--looking sale.store table for store_id, store_name
SELECT *
FROM sale.store;


--calculating revenue to every item of every order 
SELECT	o.order_id, 
		customer_id, 
		store_name, 
		order_date, 
		quantity, 
		list_price, 
		discount, 
		quantity * list_price * (1 - discount) revenue

FROM	sale.orders o, 
		sale.order_item oi,
		sale.store s

WHERE o.order_id = oi.order_id AND o.store_id = s.store_id;


----------finding highest revenue in the 4th, 5th, and 6th months of 2019 by store_name
SELECT TOP 1 store_name, 
		MAX(quantity * list_price * (1 - discount)) total_revenue

FROM	sale.orders o, 
		sale.order_item oi, 
		sale.store s

WHERE o.order_id = oi.order_id AND o.store_id = s.store_id
		AND order_date LIKE '2019-0[4-6]-%'

GROUP BY store_name
ORDER BY total_revenue DESC ;



---- 2. Report the name, surname, and city information of the customers who placed orders in both 2017 and 2018.----

--looking sale.customers table for customer_id, first_name, last_name, city
SELECT  customer_id, 
	first_name, 
	last_name, 
	city
FROM sale.customer;


--looking sale.orders table for customer_id, order_date
SELECT	customer_id, 
		order_date
FROM sale.orders;


--looking sale.orders table into year of order_ date = 2017
SELECT	customer_id, 
	order_date
FROM sale.orders
WHERE YEAR(order_date) = 2017;


--looking sale.orders table into year of order_ date = 2018
SELECT	customer_id, 
		order_date
FROM sale.orders
WHERE YEAR(order_date) = 2018;


--getting customers who ordered in 2017 or 2018
SELECT	DISTINCT first_name, 
	last_name, city, 
	YEAR(order_date) order_year
FROM sale.orders o, sale.customer c
WHERE o.customer_id = c.customer_id
		AND YEAR(order_date) IN (2017, 2018)
ORDER BY first_name;


---------getting customers who ordered in 2017 or 2018
SELECT	DISTINCT first_name, 
		last_name, 
		city

FROM	sale.orders o, 
		sale.customer c

WHERE o.customer_id = c.customer_id
		AND YEAR(order_date) IN (2017, 2018)

ORDER BY first_name;


--ALTERNATE SOLUTION 2: making joining table

----------getting customers who ordered in 2017 or 2018
SELECT	DISTINCT first_name, 
		last_name, 
		city

FROM sale.orders o
		INNER JOIN sale.customer c ON o.customer_id = c.customer_id

WHERE YEAR(order_date) IN (2017, 2018)
ORDER BY first_name;



---- 3. Products sold in cities where more than 15 orders were placed in the state of Texas in 2019.----

--looking sale.customers table for customer_id, city, state
SELECT	customer_id, 
		city, 
		[state]
FROM sale.customer;


--looking sale.orders table for order_id, customer_id, order_date
SELECT	order_id, 
		customer_id, 
		order_date
FROM sale.orders;


--looking sale.order_orders table for order_id, product_id, quantity, list_price, discount
SELECT	order_id, 
		product_id, 
		quantity, 
		list_price, 
		discount
FROM sale.order_item;


--looking product.product table for product_id, product_name
SELECT	product_id, 
		product_name
FROM product.product;


--joining all relatite tables and rows
SELECT	o.order_id, 
		o.customer_id, 
		city, 
		[state], 
		order_date, 
		oi.product_id, 
		product_name, 
		quantity, 
		oi.list_price, 
		discount 

FROM	sale.customer c, 
		sale.orders o, 
		sale.order_item oi, 
		product.product p 

WHERE	c.customer_id = o.customer_id 
		AND o.order_id = oi.order_id
		AND oi.product_id = p.product_id
		AND YEAR(order_date) = 2019
		AND state = 'TX'

ORDER BY city, o.order_id, o.customer_id,oi.product_id;



--finding total orders by every cities of TX
SELECT city, COUNT(*)
FROM	sale.customer c, 
		sale.orders o, 
		sale.order_item oi, 
		product.product p 

WHERE	c.customer_id = o.customer_id 
		AND o.order_id = oi.order_id
		AND oi.product_id = p.product_id
		AND YEAR(order_date) = 2019
		AND state = 'TX'

GROUP BY city
ORDER BY city;



--finding total orders by every cities of TX is more than 15
SELECT city, COUNT(*)
FROM	sale.customer c, 
		sale.orders o, 
		sale.order_item oi, 
		product.product p
		 
WHERE	c.customer_id = o.customer_id 
		AND o.order_id = oi.order_id
		AND oi.product_id = p.product_id
		AND YEAR(order_date) = 2019
		AND state = 'TX'
GROUP BY city
HAVING COUNT(*)> 15
ORDER BY city



--------------finding product_name that has total orders by every cities of TX is more than 15 with subquery
SELECT DISTINCT product_name
FROM	sale.customer c, 
		sale.orders o, 
		sale.order_item oi, 
		product.product p 

WHERE	c.customer_id = o.customer_id 
		AND o.order_id = oi.order_id
		AND oi.product_id = p.product_id
		AND YEAR(order_date) = 2019
		AND state = 'TX'
		AND city in (
					SELECT city
					FROM	sale.customer c, 
							sale.orders o, 
							sale.order_item oi, 
							product.product p
							 
					WHERE	c.customer_id = o.customer_id 
							AND o.order_id = oi.order_id
							AND oi.product_id = p.product_id
							AND YEAR(order_date) = 2019
							AND state = 'TX'

					GROUP BY city
					HAVING COUNT(*)> 15)
ORDER BY product_name;


--ALTERNATITE SOLUTION2 
----------------finding product_name that has total orders by every cities of TX is more than 15 with cta
WITH T1 AS (
					SELECT	o.order_id, 
							o.customer_id, 
							city, 
							product_name

					FROM	sale.customer c, 
							sale.orders o, 
							sale.order_item oi, 
							product.product p 

					WHERE	c.customer_id = o.customer_id 
							AND o.order_id = oi.order_id
							AND oi.product_id = p.product_id
							AND YEAR(order_date) = 2019
							AND state = 'TX'),
T2 AS (
					SELECT city
					FROM  T1 
					GROUP BY city
					HAVING COUNT(order_id)> 15

)

SELECT DISTINCT product_name
FROM T1, T2
WHERE T1.city IN (T2.city)
ORDER BY product_name; 