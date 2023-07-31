-----------------------PART0: getting source file, creating base tables, relations, normalizations

--creating database by English language
CREATE DATABASE  e_commerce COLLATE SQL_Latin1_General_CP1_CI_AS;
USE e_commerce;
GO

-->>>>>>>>>>	CREATE: first table, ORDER table
CREATE TABLE [dbo].[order](
order_id VARCHAR(10) NOT NULL, 
customer_id VARCHAR(10) NOT NULL, 
product_id VARCHAR(10) NOT NULL, 
shipping_id VARCHAR(10) NOT NULL, 
order_date DATE NOT NULL, 
shipping_date DATE NOT NULL,     
customer_name VARCHAR(40) NOT NULL , 
province VARCHAR(40) NOT NULL, --this will turn into id number
region VARCHAR(40) NOT NULL, --this will turn into id number
customer_segment VARCHAR(15) NOT NULL, --this will turn into id number
sales INT NOT NULL,
order_quantity TINYINT NOT NULL, 
order_priority VARCHAR(15) NOT NULL, --this will turn into id number
days_taken_for_shipping TINYINT NOT NULL
);

--READ: getting dataset from csv file
BULK INSERT [dbo].[order]
FROM 'D:\repositories\datasets\e_commerce_data.csv'
WITH (
   FIELDTERMINATOR = ';',
   ROWTERMINATOR = '\n',   
   FIRSTROW = 2           
);


					--<<<CLEAR ATTRIBUTE
--column update
UPDATE [dbo].[order]
SET	
	order_id = REPLACE(order_id, 'Ord_', ''), -- order_id =RIGHT(order_id, 4)
	customer_id = REPLACE(customer_id, 'Cust_', ''),
	product_id = REPLACE(product_id, 'Prod_', ''), 
	shipping_id = REPLACE(shipping_id, 'SHP_', ''),
	customer_segment = LOWER(customer_segment),
	order_priority = LOWER(order_priority);  

--changing data type
ALTER TABLE [dbo].[order] 
ALTER COLUMN order_id INT NOT NULL;

ALTER TABLE [dbo].[order] 
ALTER COLUMN customer_id INT NOT NULL;

ALTER TABLE [dbo].[order] 
ALTER COLUMN product_id INT NOT NULL;

ALTER TABLE [dbo].[order] 
ALTER COLUMN shipping_id INT  NOT NULL;


----writing function for string attribute by first letter uppercase
GO
CREATE FUNCTION [dbo].[first_upper](@text NVARCHAR(40))
RETURNS NVARCHAR(40)
AS
BEGIN
	DECLARE @total_space TINYINT = 0;
	DECLARE @loop TINYINT = 0;
	DECLARE @sposition TINYINT = 1;
	DECLARE @eposition TINYINT = 0;
	
	DECLARE @new_text NVARCHAR(30)='';
	
	SET @total_space = LEN(@text) - LEN(REPLACE(@text, ' ' ,''));

	IF @total_space > 0

		WHILE @loop <=@total_space	
			BEGIN				
				IF @loop = @total_space
					SET @eposition = LEN(@text);
				ELSE
					SET @eposition = CHARINDEX(' ', @text);		
				
				SET @loop = @loop + 1; 
				SET @new_text = @new_text+ SUBSTRING(@text, @sposition, 1) + LOWER(SUBSTRING(@text, @sposition+1, @eposition-1));
				SET @sposition = @eposition;
				SET @text = STUFF(@text, CHARINDEX(' ', @text), 1, '');
			END
	ELSE 
		SET @new_text = SUBSTRING(@text, 1, 1) + LOWER(SUBSTRING(@text, 2, LEN(@text)));
	
  RETURN @new_text;
END;
GO

--applying first letter uppercase
UPDATE [dbo].[order] 
SET
	customer_name = [dbo].[first_upper](customer_name),
	province = [dbo].[first_upper](province),
	region = [dbo].[first_upper](region);


			-->>>>>>>>>>	CREATE: exporting CUSTOMER table from order table
SELECT DISTINCT customer_id,customer_name, province, region, customer_segment INTO [dbo].[customer]
FROM [dbo].[order] 
ORDER BY customer_id;


--<<<CLEAR: wiping out remnants of customer table in order table
ALTER TABLE [dbo].[order]
DROP COLUMN customer_name, province, region, customer_segment;


			-->>>>>>>>>>	CREATE: exporting PROVINCE table from customer table
SELECT 
	ROW_NUMBER() OVER(ORDER BY province) province_id, 
	province province_name INTO [dbo].[province]
FROM (
	SELECT DISTINCT province
	FROM customer) pro;

-- selecting provice_name for changing into id number
SELECT p.province_id
FROM customer c
	INNER JOIN province p ON c.province = p.province_name;

			--->>>>>UPDATE: renaming province(include string) into number in customer table
UPDATE customer
SET 
	province = p.province_id
FROM customer c
	INNER JOIN province p ON c.province = p.province_name;

--renaming province column name
EXEC sp_rename 'customer.province', 'province_id', 'COLUMN';



			-->>>>>>>>>>	CREATE: exporting REGION table from customer table
SELECT 
	ROW_NUMBER() OVER(ORDER BY region) region_id, 
	region region_name INTO [dbo].[region]
FROM (
	SELECT DISTINCT region
	FROM customer) reg;

-- selecting region_name for changing into id number
SELECT r.region_id
FROM customer c
	INNER JOIN region r ON c.region = r.region_name;

			--->>>>>UPDATE: renaming region(include string) into number in customer table
UPDATE customer
SET
	region = r.region_id
FROM customer c
	INNER JOIN region r ON c.region = r.region_name;

--renaming region column name
EXEC sp_rename 'customer.region', 'region_id', 'COLUMN';



			-->>>>>>>>>>	CREATE: exporting CUSTOMER_SEGMENT table from customer table
SELECT 
	ROW_NUMBER() OVER(ORDER BY customer_segment) customer_segment_id, 
	customer_segment customer_segment_name INTO customer_segment
FROM (
	SELECT DISTINCT customer_segment
	FROM customer) cus_seg;

-- selecting customer_segment_name for changing into id number
SELECT cs.customer_segment_id
FROM customer c
	INNER JOIN customer_segment cs ON  c.customer_segment = cs.customer_segment_name;

			--->>>>>UPDATE: renaming customer_segment(include string) into number in customer table
UPDATE customer
SET customer_segment = cs.customer_segment_id
FROM customer c
	INNER JOIN customer_segment cs ON  c.customer_segment = cs.customer_segment_name;

--renaming customer_segment column name
EXEC sp_rename 'customer.customer_segment', 'customer_segment_id', 'COLUMN';



			-->>>>>>>>>>	CREATE: exporting SHIPPING table from order table
SELECT DISTINCT shipping_id, shipping_date, days_taken_for_shipping INTO [dbo].[shipping]
FROM [dbo].[order]
ORDER BY shipping_id;


--<<<CLEAR: wiping out remnants of shipping table in customer table
ALTER TABLE [dbo].[order]
DROP COLUMN shipping_date, days_taken_for_shipping;



			-->>>>>>>>>>	CREATE: exporting ORDER_PRIORITY table from order table
SELECT 
	ROW_NUMBER() OVER(ORDER BY order_priority) order_priority_id, 
	order_priority order_priority_type INTO [dbo].[order_priority]
FROM (
	SELECT DISTINCT order_priority
	FROM [dbo].[order]) ord_pri;

-- selecting order_priority_name for changing into id number
SELECT op.order_priority_id
FROM [dbo].[order] o
	INNER JOIN order_priority op ON  o.order_priority = op.order_priority_type;

			--->>>>>UPDATE: renaming order_priority(include string) into number in customer table
UPDATE [dbo].[order]
SET
	order_priority  = op.order_priority_id 
FROM [dbo].[order] o 
	INNER JOIN order_priority op ON  o.order_priority = op.order_priority_type;

--renaming order_priority column name
EXEC sp_rename '[dbo].[order].order_priority', 'order_priority_id', 'COLUMN';



			-->>>>>>>>>>	CREATE: exporting ORDER_ITEM table from order table
SELECT order_id, 
	ROW_NUMBER() OVER(PARTITION BY order_id ORDER BY order_id) item_id,
	product_id, sales, order_quantity INTO [dbo].[order_item]
FROM [dbo].[order]
ORDER BY order_id;


--<<<CLEAR: wiping out remnants of order item in customer table
ALTER TABLE [dbo].[order]
DROP COLUMN product_id, sales, order_quantity;




--xxxDELETE: clearing dublicate records in order table
DELETE t1
FROM (
		SELECT *, dub_row_num = ROW_NUMBER() OVER(PARTITION BY order_id order BY (SELECT NULL))

		FROM [dbo].[order]) AS T1
WHERE dub_row_num > 1;

---alternative way
WITH CTE AS(
			SELECT *, dub_row_num = ROW_NUMBER() OVER(PARTITION BY order_id order BY (SELECT NULL))
			FROM [dbo].[order]
			)
DELETE FROM CTE WHERE dub_row_num > 1;


------------------------REARRANGE: determining primary key and foreign key attributes

ALTER TABLE [dbo].[customer_segment]
ALTER COLUMN [customer_segment_id] INT NOT NULL;
GO
ALTER TABLE [dbo].[customer_segment]
ADD CONSTRAINT PK_customer_segment PRIMARY KEY(customer_segment_id);
GO

ALTER TABLE [dbo].[region]
ALTER COLUMN [region_id] INT NOT NULL;
GO
ALTER TABLE [dbo].[region]
ADD CONSTRAINT PK_region PRIMARY KEY(region_id);
GO

ALTER TABLE [dbo].[province]
ALTER COLUMN [province_id] INT NOT NULL;
GO
ALTER TABLE [dbo].[province]
ADD CONSTRAINT PK_province PRIMARY KEY(province_id);
GO
ALTER TABLE [dbo].[customer]
ALTER COLUMN [customer_id] INT NOT NULL;
GO

ALTER TABLE [dbo].[customer]
ALTER COLUMN [province_id] INT NOT NULL;

ALTER TABLE [dbo].[customer]
ALTER COLUMN [region_id] INT NOT NULL;

ALTER TABLE [dbo].[customer]
ALTER COLUMN [customer_segment_id] INT NOT NULL;


ALTER TABLE [dbo].[customer]
ADD CONSTRAINT PK_customer PRIMARY KEY(customer_id),
CONSTRAINT FK_customer_p FOREIGN KEY(province_id) REFERENCES [dbo].[province] (province_id),
CONSTRAINT FK_customer_r FOREIGN KEY(region_id) REFERENCES [dbo].[region] (region_id),
CONSTRAINT FK_customer_cs FOREIGN KEY(customer_segment_id) REFERENCES [dbo].[customer_segment] (customer_segment_id);

GO
ALTER TABLE [dbo].[shipping]
ALTER COLUMN [shipping_id] INT NOT NULL;
GO
ALTER TABLE [dbo].[shipping]
ADD CONSTRAINT PK_shipping PRIMARY KEY(shipping_id);
GO

ALTER TABLE [dbo].[order_priority]
ALTER COLUMN [order_priority_id] INT NOT NULL;
GO
ALTER TABLE [dbo].[order_priority]
ADD CONSTRAINT PK_order_priority PRIMARY KEY(order_priority_id);
GO

ALTER TABLE [dbo].[order]
ADD CONSTRAINT PK_order PRIMARY KEY(order_id);
GO
ALTER TABLE [dbo].[order]
ADD CONSTRAINT FK_order_customer FOREIGN KEY(customer_id) REFERENCES [dbo].[customer](customer_id);
GO
ALTER TABLE [dbo].[order]
ADD CONSTRAINT FK_order_shipping FOREIGN KEY(shipping_id) REFERENCES [dbo].[shipping] (shipping_id);
GO
ALTER TABLE [dbo].[order]
ALTER COLUMN [order_priority_id] INT NOT NULL;

ALTER TABLE [dbo].[order]
ADD CONSTRAINT FK_order_priority FOREIGN KEY(order_priority_id) REFERENCES [dbo].[order_priority](order_priority_id);
GO

ALTER TABLE [dbo].[order_item]
ALTER COLUMN [order_id] INT NOT NULL;
GO
ALTER TABLE [dbo].[order_item]
ALTER COLUMN [item_id] INT NOT NULL;
GO
ALTER TABLE [dbo].[order_item]
ALTER COLUMN [product_id] INT NOT NULL;
GO

ALTER TABLE [dbo].[order_item]
ADD CONSTRAINT PK_order_item  PRIMARY KEY(order_id, item_id);
GO
ALTER TABLE [dbo].[order_item]
ADD CONSTRAINT FK_order_item_order FOREIGN KEY(order_id) REFERENCES [dbo].[order](order_id);
GO

----------------------------------------------------------------------------

-----------------------PART1: Analyze the data by finding the answers to the questions below:
--1. Find the top 3 customers who have the maximum count of orders.

--finding top 3 customer who have the maximum count of orders
SELECT TOP 3 o.customer_id, 
			c.customer_name,
			COUNT(DISTINCT o.order_id) total_order
FROM [order] o
	INNER JOIN order_item oi ON o.order_id = oi.order_id
	INNER JOIN customer c ON o.customer_id = c.customer_id
GROUP BY o.customer_id, c.customer_name
ORDER BY total_order DESC;

-- with window functions
SELECT DISTINCT TOP 3 o.customer_id, 
				c.customer_name,
				COUNT(o.order_id) OVER(PARTITION BY o.customer_id, oi.item_id) total_order
FROM [order] o
	INNER JOIN order_item oi ON o.order_id = oi.order_id
	INNER JOIN customer c ON o.customer_id = c.customer_id
ORDER BY total_order DESC


--2. Find the customer whose order took the maximum time to get shipping.
SELECT  TOP 1 o.customer_id, c.customer_name, o.order_date, s.shipping_date, s.days_taken_for_shipping
FROM [order] o
	INNER JOIN shipping s ON o.shipping_id = s.shipping_id
	INNER JOIN customer c ON o.customer_id = c.customer_id
ORDER BY s.days_taken_for_shipping DESC

--3. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011

SELECT COUNT(DISTINCT customer_id) count_of_unique_customer
FROM [order];

--Count the total number of unique customers in January
SELECT COUNT(DISTINCT customer_id) count_of_unique_customer
FROM [order]
WHERE order_date LIKE '2011-01-%';

SELECT customer_id
FROM [order]
WHERE order_date LIKE '2011-01-%'
ORDER BY customer_id;


--finding all 2011 visit
SELECT *
FROM [order]
WHERE customer_id IN (
					SELECT customer_id
					FROM [order]
					WHERE order_date LIKE '2011-01-%'
					)
AND YEAR(order_date) = 2011 
ORDER BY customer_id, order_date;


SELECT DATENAME(MONTH, order_date) month_name, COUNT(DISTINCT order_id) total_came_back_customer-- no need distinct
FROM [order]
WHERE customer_id IN (
					SELECT customer_id
					FROM [order]
					WHERE order_date LIKE '2011-01-%'
					)
AND YEAR(order_date) = 2011 
GROUP BY  DATENAME(MONTH, order_date);

--with window
WITH CTE AS (
SELECT DISTINCT
		MONTH(order_date) month_number,
		DATENAME(MONTH, order_date) month_name,
		COUNT(order_id) OVER(PARTITION BY MONTH(order_date)) total_came_back_customer
FROM [order]
WHERE customer_id IN (
					SELECT customer_id
					FROM [order]
					WHERE order_date LIKE '2011-01-%'
					)
AND YEAR(order_date) = 2011
)
SELECT month_name, total_came_back_customer
FROM CTE
WHERE month_number > 1
ORDER BY month_number;


--4. Write a query to return for each user the time elapsed between the first purchasing and the third purchasing, in ascending order by Customer ID.

SELECT customer_id, order_id, order_date
FROM [order]
ORDER BY customer_id, order_date;


SELECT customer_id, COUNT(order_id) total_order--order_id, order_date
FROM [order]
GROUP BY customer_id
ORDER BY customer_id;


WITH CTE AS
(
SELECT	customer_id, 
		order_date,
		FIRST_VALUE(order_date)	OVER(PARTITION BY customer_id ORDER BY order_date) first_visit,
		LEAD(order_date, 2) OVER (PARTITION BY customer_id ORDER BY order_date) third_visit,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) item_number
FROM [order]
)
SELECT customer_id, first_visit, third_visit,
		--CAST(DATEDIFF(DAY, first_order,third_order) AS nvarchar(6)) + ' days' time_elapsed_first_third_days	
		CASE WHEN DATEDIFF(DAY, first_visit,third_visit) IS NOT NULL THEN 
		CAST(DATEDIFF(DAY, first_visit,third_visit) AS nvarchar(6)) + ' days' 
		ELSE 'NO THIRD VISIT' END  time_elapsed_first_third_days	
FROM CTE
WHERE item_number = 1
ORDER BY customer_id;


--5. Write a query that returns customers who purchased both product 11 and product 14, as well as the ratio of these products to the total number of products purchased by the customer.


WITH CTE AS 
(
SELECT o.customer_id,customer_name, product_id, o.order_date, order_quantity
FROM [order] o
	INNER JOIN order_item oi ON o.order_id = oi.order_id
	INNER JOIN customer c ON o.customer_id = c.customer_id
), CTE2 AS
(
SELECT DISTINCT customer_id, customer_name, product_id,
		SUM (order_quantity) OVER(PARTITION BY customer_id, product_id) total_quantity,
		SUM (order_quantity) OVER(PARTITION BY customer_id) total_order_quantity
FROM CTE
WHERE customer_id IN(SELECT customer_id
					FROM CTE
					WHERE product_id = 11
					INTERSECT
					SELECT customer_id
					FROM CTE
					WHERE product_id = 14
					)
) 
SELECT customer_id, customer_name, product_id, FORMAT(ROUND(total_quantity *1.0  / total_order_quantity, 6), 'P', 'EN-US')  ratio
FROM CTE2 
WHERE product_id IN (11, 14)
ORDER BY customer_id, product_id;


------------------------------------------------
-----------------------PART2: Customer Segmentation
--Categorize customers based on their frequency of visits. The following steps will guide you. If you want, you can track your own way.
--1. Create a “view” that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)

GO
CREATE VIEW vw_customer_visit_log AS
SELECT DISTINCT customer_id, YEAR(order_date) visit_year, MONTH(order_date) visit_month
FROM [order] o;
GO


--clearing explicit
SELECT DISTINCT o.customer_id, customer_name, YEAR(order_date) visit_year, DATENAME(MONTH, order_date) visit_month
FROM [order] o
	INNER JOIN customer c ON o.customer_id = c.customer_id;



--2. Create a “view” that keeps the number of monthly visits by users. (Show separately all months from the beginning business)

GO
CREATE VIEW vw_customer_visit_total AS
SELECT DISTINCT customer_id, YEAR(order_date) visit_year, MONTH(order_date) visit_month, 
	COUNT(customer_id) OVER(PARTITION BY customer_id, YEAR(order_date),  MONTH(order_date)) total_visit
FROM [order] o
 GO
 
SELECT *
FROM vw_customer_visit_total;

--clearifying table
GO
CREATE VIEW vw_customer_visit_year_montly_total AS
WITH CTE AS (
SELECT *
FROM (
		SELECT o.customer_id, c.customer_name,
				YEAR(order_date) [year],
				DATENAME(MONTH, order_date) order_month,
				COUNT(o.customer_id) OVER(PARTITION BY o.customer_id, YEAR(order_date), DATENAME(MONTH, order_date)) total_order		
		FROM [order] o
			INNER JOIN customer c ON o.customer_id = c.customer_id
		) AS t1
PIVOT 
	(	
	COUNT(  order_month)
	FOR order_month
		IN ([January],[February],[March],[April], [May], [June], [July], [August], [September], [October], [November], [December] )
	) AS PV
			)
SELECT *
FROM CTE
GO

--showing view 
SELECT *
FROM vw_customer_visit_year_montly_total;

--3. For each visit of customers, create the next month of the visit as a separate column.

--looking first visit and next visit by customer_id and order_id
WITH CTE AS (
SELECT customer_id, order_date first_visit ,
	LEAD(order_date) OVER(PARTITION BY customer_id ORDER BY order_date)	next_visit	
FROM [order]
)
SELECT * 
FROM CTE;


--creating view for showing all visit new column by customer_id
GO
CREATE VIEW vw_visit_show AS
WITH CTE AS
(
SELECT customer_id,
		order_date,
		LEAD(order_date) OVER(PARTITION BY customer_id ORDER BY order_date)	next_visit,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) visit_number
FROM [order]
), CTE2 AS
(
SELECT	customer_id,
		MAX(CASE WHEN visit_number = 1 THEN next_visit END) visit_2,
		MAX(CASE WHEN visit_number = 2 THEN next_visit END) visit_3,
		MAX(CASE WHEN visit_number = 3 THEN next_visit END) visit_4,
		MAX(CASE WHEN visit_number = 4 THEN next_visit END) visit_5,
		MAX(CASE WHEN visit_number = 5 THEN next_visit END) visit_6,
		MAX(CASE WHEN visit_number = 6 THEN next_visit END) visit_7,
		MAX(CASE WHEN visit_number = 7 THEN next_visit END) AS visit_8,
		MAX(CASE WHEN visit_number = 8 THEN next_visit END) AS visit_9,
		MAX(CASE WHEN visit_number = 9 THEN next_visit END) AS visit_10,
		MAX(CASE WHEN visit_number = 10 THEN next_visit END) AS visit_11,
		MAX(CASE WHEN visit_number = 11 THEN next_visit END) AS visit_12,
		MAX(CASE WHEN visit_number = 12 THEN next_visit END) AS visit_13,
		MAX(CASE WHEN visit_number = 13 THEN next_visit END) AS visit_14,
		MAX(CASE WHEN visit_number = 14 THEN next_visit END) AS visit_15,
		MAX(CASE WHEN visit_number = 15 THEN next_visit END) AS visit_16,
		MAX(CASE WHEN visit_number = 16 THEN next_visit END) AS visit_17
FROM CTE
GROUP BY customer_id
), CTE3 AS
(
SELECT DISTINCT customer_id, 
	COUNT(customer_id) OVER(PARTITION BY customer_id) visit_number,
	FIRST_VALUE(order_date) OVER(PARTITION BY customer_id ORDER BY order_date ) visit_1
FROM [order]
)
SELECT CTE3.*, CTE2.visit_2, CTE2.visit_3, CTE2.visit_4, CTE2.visit_5, CTE2.visit_6, CTE2.visit_7, CTE2.visit_8, CTE2.visit_9, CTE2.visit_10, CTE2.visit_11, CTE2.visit_12, CTE2.visit_13, CTE2.visit_14, CTE2.visit_15, CTE2.visit_16, CTE2.visit_17
FROM CTE3
	LEFT JOIN CTE2 ON CTE3.customer_id = CTE2.customer_id;
GO

--showing view 
SELECT *
FROM vw_visit_show;


--4. Calculate the monthly time gap between two consecutive visits by each customer.

WITH CTE AS
(
SELECT customer_id,
		order_date,
		LEAD(order_date) OVER(PARTITION BY customer_id ORDER BY order_date)	next_visit,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) visit_number,
		COUNT(customer_id) OVER(PARTITION BY customer_id)-1 visit_gap_number
FROM [order]
)
SELECT CTE.customer_id, visit_gap_number,
		MAX(CASE WHEN visit_number = 1 AND visit_gap_number = 0 THEN 0 END) gap_0,
		MAX(CASE WHEN visit_number = 1 THEN DATEDIFF(MONTH, order_date,next_visit) END) gap_1,
		MAX(CASE WHEN visit_number = 2 THEN DATEDIFF(MONTH, order_date,next_visit) END) gap_2,	
		MAX(CASE WHEN visit_number = 3 THEN DATEDIFF(MONTH, order_date,next_visit) END) gap_3,
		MAX(CASE WHEN visit_number = 4 THEN DATEDIFF(MONTH, order_date,next_visit) END) gap_4,
		MAX(CASE WHEN visit_number = 5 THEN DATEDIFF(MONTH, order_date,next_visit) END) gap_5,
		MAX(CASE WHEN visit_number = 6 THEN DATEDIFF(MONTH, order_date,next_visit) END) gap_6,
		MAX(CASE WHEN visit_number = 7 THEN DATEDIFF(MONTH, order_date,next_visit) END) gap_7,
		MAX(CASE WHEN visit_number = 8 THEN DATEDIFF(MONTH, order_date,next_visit) END) gap_8,
		MAX(CASE WHEN visit_number = 9 THEN DATEDIFF(MONTH, order_date,next_visit) END) gap_9,
		MAX(CASE WHEN visit_number = 10 THEN DATEDIFF(MONTH, order_date,next_visit) END) gap_10,
		MAX(CASE WHEN visit_number = 11 THEN DATEDIFF(MONTH, order_date,next_visit) END) gap_11,
		MAX(CASE WHEN visit_number = 12 THEN DATEDIFF(MONTH, order_date,next_visit) END) gap_12,
		MAX(CASE WHEN visit_number = 13 THEN DATEDIFF(MONTH, order_date,next_visit) END) gap_13,
		MAX(CASE WHEN visit_number = 14 THEN DATEDIFF(MONTH, order_date,next_visit) END) gap_14,
		MAX(CASE WHEN visit_number = 15 THEN DATEDIFF(MONTH, order_date,next_visit) END) gap_15,
		MAX(CASE WHEN visit_number = 16 THEN DATEDIFF(MONTH, order_date,next_visit) END) gap_16
		
FROM CTE
GROUP BY customer_id, visit_gap_number
ORDER BY customer_id;



--5. Categorise customers using average time gaps. Choose the most fitted labeling model for you.
-----For example:
--------o Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
--------o Labeled as regular if the customer has made a purchase every month. Etc.
WITH CTE AS
(
SELECT customer_id,
		order_date,
		LEAD(order_date) OVER(PARTITION BY customer_id ORDER BY order_date)	next_visit,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) visit_number,
		COUNT(customer_id) OVER(PARTITION BY customer_id)-1 visit_gap_number
FROM [order]
), CTE2 AS
(
SELECT *, CAST(DATEDIFF(MONTH, order_date, next_visit) AS FLOAT) gap_monthly
FROM  CTE
GROUP BY customer_id,order_date,next_visit,visit_number, visit_gap_number
), CTE3 AS
(
SELECT *,
	CAST(AVG(gap_monthly) OVER(PARTITION BY customer_id) AS decimal(4,2)) avg_time_gaps
FROM CTE2
)
SELECT DISTINCT customer_id, --visit_gap_number, 
		CASE	WHEN avg_time_gaps IS NULL THEN 'churn'
				WHEN avg_time_gaps <2 THEN 'loyal'
				WHEN  avg_time_gaps <=6 THEN 'regular'
				WHEN  avg_time_gaps <= 12 THEN 'inactive'
				ELSE 'win-back'
		END retentation
FROM CTE3;


------------------------------------------------
-----------------------PART3:Month-Wise Retention Rate
/*Find month-by-month customer retention ratei since the start of the business.
There are many different variations in the calculation of Retention Rate. 
But we will try to calculate the month-wise retention rate in this project.
So, we will be interested in how many of the customers in the previous month could be retained in the next month.
Proceed step by step by creating “views”. 
You can use the view you got at the end of the Customer Segmentation section as a source.*/

--1. Find the number of customers retained month-wise. (You can use time gaps)

--creating function for last month of year
CREATE FUNCTION dbo.GetEndDate(@start_year INT, @start_month INT)
RETURNS TABLE AS RETURN
(
    SELECT 
        CASE 
            WHEN @start_month = 12 THEN @start_year + 1
            ELSE @start_year
        END AS end_year,
        CASE
            WHEN @start_month = 12 THEN 1
            ELSE @start_month + 1
        END AS end_month
)

--creating function for calculating monthly retantion
CREATE FUNCTION dbo.monthly_retention(@start_year INT, @start_month INT)
RETURNS INT
AS BEGIN
DECLARE @retentation INT;
DECLARE @end_year INT, @end_month INT;
	
	SELECT @end_year = end_year, @end_month = end_month
    FROM dbo.GetEndDate(@start_year, @start_month);

WITH CTE AS
(
	SELECT customer_id, order_id,
        YEAR(order_date) AS year,
        MONTH(order_date) AS month        
    FROM [order]
), CTE2 AS
(
		SELECT customer_id
		FROM CTE
		WHERE [year]=@start_year AND [month] = @start_month
		INTERSECT
		SELECT customer_id
		FROM CTE
		WHERE [year]=@end_year AND [month] = @end_month
)
SELECT @retentation = COUNT(customer_id)
FROM CTE2;
RETURN @retentation;
END;

GO

--creating retation table 
CREATE TABLE monthly_retention_table (
    [year] INT,
    [month] INT,
    [retention] INT
);
--insert into retation table 
DECLARE @year INT = 2009;
DECLARE @month INT = 1;
WHILE (@year <= 2012 AND @month <= 12)
BEGIN
    INSERT INTO monthly_retention_table (year, month, retention)
    VALUES (@year, @month, dbo.monthly_retention(@year, @month));
    
    SET @month = @month + 1;
    IF @month > 12
    BEGIN
        SET @month = 1;
        SET @year = @year + 1;
    END
END;

--showing montly retantion
SELECT *
FROM monthly_retention_table
PIVOT (
    MAX(retention)
    FOR Month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS pvt;



--2. Calculate the month-wise retention rate.
--Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Current Month / Total Number of Customers in the Current Month

WITH CTE AS
(
    SELECT DISTINCT YEAR(order_date) [year], 
					MONTH(order_date) [month],
					COUNT(customer_id) OVER(PARTITION BY YEAR(order_date), MONTH(order_date)) total_customer_by_month
    FROM [order] 
), CTE2 AS 
(
SELECT t.[year], t.[month],  CAST(([retention] * 1.0 / CTE.total_customer_by_month) AS DECIMAL(5,4)) retention_rate
FROM monthly_retention_table t
INNER JOIN CTE ON t.year = CTE.year AND t.month = CTE.month
)
SELECT *
FROM CTE2
PIVOT (
    MAX(retention_rate)
	FOR Month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS pvt;






