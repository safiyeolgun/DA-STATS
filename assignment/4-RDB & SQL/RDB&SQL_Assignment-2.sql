
--1. Product Sales

--You need to create a report on whether customers who purchased the product named '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD' buy the product below or not.
--1. 'Polk Audio - 50 W Woofer - Black' -- (other_product)
--To generate this report, you are required to use the appropriate SQL Server Built-in functions or expressions as well as basic SQL knowledge.

USE SampleRetail;
GO

--looking product.product for product name, product_id
SELECT *
FROM product.product
WHERE product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
	OR product_name = 'Polk Audio - 50 W Woofer - Black';


--looking sale.order_item for order_id and product_id
SELECT *
FROM sale.order_item;

--looking sale.orders for order_id nad customer_id
SELECT *
FROM sale.orders;

--looking sale.customer for customer_id and first_name
SELECT *
FROM sale.customer;


--finding customer who buy '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
SELECT DISTINCT c.customer_id, first_name, last_name, oi.product_id, product_name
FROM sale.orders o
	INNER JOIN sale.customer c ON o.customer_id = c.customer_id
	INNER JOIN sale.order_item oi ON o.order_id = oi.order_id
	INNER JOIN product.product p  ON oi.product_id = p.product_id
WHERE product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
ORDER BY c.customer_id;


--finding customer who buy 'Polk Audio - 50 W Woofer - Black'
SELECT DISTINCT c.customer_id, first_name, last_name, oi.product_id, product_name
FROM sale.orders o
	INNER JOIN sale.customer c ON o.customer_id = c.customer_id
	INNER JOIN sale.order_item oi ON o.order_id = oi.order_id
	INNER JOIN product.product p  ON oi.product_id = p.product_id
WHERE product_name = 'Polk Audio - 50 W Woofer - Black'
ORDER BY c.customer_id;


--finding with who buy 'TB...' but not buy 'Polk...' CTEs
WITH 
T1 AS (
		SELECT c.customer_id, first_name, last_name, oi.product_id, product_name
		FROM sale.orders o
		INNER JOIN sale.customer c ON o.customer_id = c.customer_id
		INNER JOIN sale.order_item oi ON o.order_id = oi.order_id
		INNER JOIN product.product p  ON oi.product_id = p.product_id
		), 
T2 AS (
		SELECT *
		FROM T1
		WHERE product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
), 
T3 AS (
		SELECT *
		FROM T1
		WHERE product_name = 'Polk Audio - 50 W Woofer - Black'
)
,
MatchTable AS (
SELECT T2.customer_id
FROM T2, T3
WHERE T2.customer_id = T3.customer_id
)
SELECT DISTINCT 
			T2.customer_id Customer_Id, 
			T2.first_name First_Name, 
			T2.last_name Last_Name, 
			CASE 
				WHEN(T3.customer_id IS NULL) then 'No' 
			ELSE 'Yes' 
			END Other_Product
FROM T2
LEFT JOIN T3 ON T2.customer_id = T3.customer_id
ORDER BY T2.customer_id;



--2. Conversion Rate
--Below you see a table of the actions of customers visiting the website by clicking on two different types of advertisements given by an E-Commerce company. Write a query to return the conversion rate for each Advertisement type


--a.    Create above table (Actions) and insert values,

--creating database
CREATE DATABASE e_commerce;

USE e_commerce;
GO

--creating table
CREATE TABLE Actions(
Visitor_ID INT,
Adv_Type CHAR(1) NOT NULL,
Action VARCHAR(10) NOT NULL
);

--inserting values into table
INSERT [dbo].[Actions] VALUES
(1, N'A', N'Left'),
(2, N'A', N'Order'),
(3, N'B', N'Left'),
(4, N'A', N'Order'),
(5, N'A', N'Review'),
(6, N'A', N'Left'),
(7, N'B', N'Left'),
(8, N'B', N'Order'),
(9, N'B', N'Review'),
(10, N'A', N'Review');
GO

--ALTERNATE SOLUTION: creating table with primarily key
CREATE TABLE Actions(
Visitor_ID INT IDENTITY (1, 1) PRIMARY KEY,
Adv_Type CHAR(1) NOT NULL,
Action VARCHAR(10) NOT NULL
);

--ALTERNATE SOLUTION: inserting values into table with primarily key values 
SET IDENTITY_INSERT Actions ON;
INSERT [dbo].[Actions] ([Visitor_ID], [Adv_Type], [Action] ) VALUES(1, N'A', N'Left')
INSERT [dbo].[Actions] ([Visitor_ID], [Adv_Type], [Action] ) VALUES(2, N'A', N'Order')
INSERT [dbo].[Actions] ([Visitor_ID], [Adv_Type], [Action] ) VALUES(3, N'B', N'Left')
INSERT [dbo].[Actions] ([Visitor_ID], [Adv_Type], [Action] ) VALUES(4, N'A', N'Order')
INSERT [dbo].[Actions] ([Visitor_ID], [Adv_Type], [Action] ) VALUES(5, N'A', N'Review')
INSERT [dbo].[Actions] ([Visitor_ID], [Adv_Type], [Action] ) VALUES(6, N'A', N'Left')
INSERT [dbo].[Actions] ([Visitor_ID], [Adv_Type], [Action] ) VALUES(7, N'B', N'Left')
INSERT [dbo].[Actions] ([Visitor_ID], [Adv_Type], [Action] ) VALUES(8, N'B', N'Order')
INSERT [dbo].[Actions] ([Visitor_ID], [Adv_Type], [Action] ) VALUES(9, N'B', N'Review')
INSERT [dbo].[Actions] ([Visitor_ID], [Adv_Type], [Action] ) VALUES(10, N'A', N'Review')
SET IDENTITY_INSERT Actions OFF;
GO


SELECT *
FROM Actions;

--b.    Retrieve count of total Actions and Orders for each Advertisement Type,

--counting total advertisement by Adv_type
SELECT Adv_Type, COUNT(Visitor_ID) as total_actions
FROM Actions
GROUP BY Adv_Type;

--counting total advertisement by action
SELECT [Action], COUNT(Visitor_ID) as total_actions
FROM Actions
GROUP BY [Action];


--counting total advertisement by Adv_type and action
SELECT Adv_Type, [Action], COUNT(Visitor_ID) as total_actions
FROM Actions
GROUP BY Adv_Type, [Action]
ORDER BY Adv_Type;


--counting of order action advertisement 
SELECT [Action], COUNT(Visitor_ID) as total_orders
FROM Actions
WHERE [Action] = 'Order'
GROUP BY [Action];

--counting of order action advertisement by Adv_type
SELECT Adv_Type, COUNT(Visitor_ID) as total_orders
FROM Actions
WHERE [Action] = 'Order'
GROUP BY Adv_Type;


--finding total advertisement with order action by Adv_type 
SELECT Adv_Type, 
		COUNT(CASE WHEN [Action] = 'Order' then 1 END) total_orders,
		COUNT(Visitor_ID) as total_actions		
FROM Actions
GROUP BY Adv_Type;


--c.    Calculate Orders (Conversion) rates for each Advertisement Type by dividing by total count of actions casting as float by multiplying by 1.0.
--turning 

--calculating order actions rate
SELECT Adv_Type, 
       CAST(
			COUNT(CASE WHEN Action = 'Order' THEN 1 END) * 1.0 / 
			COUNT(Adv_Type) AS DECIMAL(3,2)
			) Conversion_Rate
FROM Actions
GROUP BY Adv_Type;