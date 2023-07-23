--Discount Effects
--Generate a report including product IDs and discount effects on whether the increase in the discount rate positively impacts the number of orders for the products.

--In this assignment, you are expected to generate a solution using SQL with a logical approach. 

--Sample Result:
--------------------------------------------
--Product_id	Discount Effect
--1		Positive
--2		Negative
--3		Negative
--4		Neutral

USE SampleRetail;

GO 
WITH CTE AS(
	SELECT *, 
			--calculation of the discount weighted average by quantity 
			CAST(SUM(discount * total_quantity)  OVER(PARTITION BY product_id) /SUM(total_quantity) OVER(PARTITION BY product_id) AS FLOAT) avg_discount,

			--calculation the difference between the discount and the discount weighted average
			CAST(SUM(discount * total_quantity)  OVER(PARTITION BY product_id) /SUM(total_quantity) OVER(PARTITION BY product_id) - discount AS FLOAT) avg_discount_diff
	FROM (
		SELECT DISTINCT oi.product_id, discount,

				--calculation of quantity to each discount of each product
				SUM(quantity) OVER(PARTITION BY oi.product_id, discount) total_quantity				
				
		FROM sale.order_item oi
			INNER JOIN product.product p ON oi.product_id = p.product_id
			INNER JOIN sale.orders o ON oi.order_id = o.order_id
		) sqry
), 
CTE2  AS(
	SELECT *, 

	--calculation the sum of the differences (discount from discount weighted average) 
	SUM(avg_discount_diff) OVER(PARTITION BY product_id)  avg_discount_diff_total
	FROM CTE )
SELECT DISTINCT product_id,

			---decision making about discount effect
		CASE	WHEN avg_discount_diff_total = 0 THEN 'Neutral' 
				WHEN avg_discount_diff_total > 0 THEN 'Positive' 
				ELSE 'Negative' 
		END discount_effect
FROM CTE2
ORDER BY product_id;



