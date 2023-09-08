USE master;
GO
--1. According the table above we run the query. 

/*
-----------------------------------
	ItemId		Client		Price
-----------------------------------
1	1			owen		100
2	1			orion		94
3	1			marie		85
4	2			owen		70
5	2			orion		72
6	2			marie		80
7	3			owen		90
8	3			orion		95
9	3			marie		85
-----------------------------------
*/
--Create temporary table
DECLARE @tempTable TABLE (ItemID INT, Client VARCHAR(25), Price INT)
INSERT @tempTable VALUES (1, 'owen', 100),
						(1, 'orion', 94),
						(1, 'marie', 85),
						(2, 'owen', 70),
						(2, 'orion', 72),
						(2, 'marie', 80),
						(3, 'owen', 90),
						(3, 'orion', 95),
						(3, 'marie', 85);

SELECT ItemId, AVG(Price) 
FROM @tempTable
GROUP BY ItemId;

--Create Client from @tempTable 
SELECT * INTO [ClientTable] FROM @tempTable;

--Show Client Table
SELECT * FROM [ClientTable];



-----------What is the avg(Price) for item 2?
SELECT ItemId, AVG(Price) 
FROM [ClientTable] --@tempTable
WHERE ItemId = 2
GROUP BY ItemId;


------------------------------------------------------------------------------------

--2. According the table above we run the query. 
SELECT Client, MAX(Price) 
FROM [ClientTable] --@tempTable
GROUP BY Client;

-----------What is the max(Price) for Marie?
SELECT Client, MAX(Price) 
FROM [ClientTable] --@tempTable
Where Client = 'marie'
GROUP BY Client;


------------------------------------------------------------------------------------
/*
-----------------------------------
	ItemId		Client		Price
-----------------------------------
1	1			owen		100
2	1			orion		94
3	1			marie		85
4	2			owen		70
5	2			orion		72
6	2			marie		80
7	3			owen		90
8	3			orion		95
9	3			marie		85
-----------------------------------
*/

--3. We have table above.

--Which SQL server operator is used to get the result below?
/*
------------------------------------------------
SUM of Price	Client
------------------------------------------------
ItemId			owen		orion		marie
------------------------------------------------
1				100			94			85
2				70			72			80
3				90			95			85
------------------------------------------------
*/

SELECT *
FROM [ClientTable] --@tempTable
PIVOT
(
	MAX(Price)
	FOR Client IN ([owen],[orion],[marie])
) AS PV;


--alternative way
SELECT ItemID, [owen],[orion],[marie]
FROM [ClientTable] --@tempTable
PIVOT
(
	MAX(Price)
	For Client IN (*[owen],[orion],[marie])
) AS PV;



------------------------------------------------------------------------------------

--4. We have table TotalSales and ZipCode. Which following functions should we user to get the first 2 columns in the picture below?
/*
-----------------------------------------
		TotalSales		ZipCode	
-----------------------------------------
1	1	2505866.81		41027
1	1	2428410.952		41027
1	1	2350955.095		41027
1	1	2273499.238		41027
1	1	2196043.381		41027
6	2	2118587.524		41055
6	2	2041131.667		41055
6	2	1963675.81		41055
6	2	1886219.952		41055
6	2	1808764.095		41055
6	2	1731308.238		41055
6	2	1653852.381		41055
6	2	1576396.524		41055
6	2	1498940.667		41055
6	2	1421484.81		41055

*/
--Create temporary table
DECLARE @tempSales TABLE (ZipCode INT, TotalSales INT)
INSERT @tempSales VALUES	(41027, 2505866.81),
							(41027, 2428410.952),
							(41027, 2350955.095),
							(41027, 2273499.238),
							(41027, 2196043.381),
							(41055, 2118587.524),
							(41055, 2041131.667),
							(41055, 1963675.81),
							(41055, 1886219.952),
							(41055, 1808764.095),
							(41055, 1731308.238),
							(41055, 1653852.381),
							(41055, 1576396.524),
							(41055, 1498940.667),
							(41055, 1421484.81);

SELECT	RANK() OVER(ORDER BY ZipCode) [rank],
		DENSE_RANK() OVER(ORDER BY ZipCode) [dense_rank],	
		TotalSales, ZipCode,
		RANK() OVER(PARTITION BY ZipCode ORDER BY TotalSales) [group_in_rank],
		DENSE_RANK() OVER(PARTITION BY ZipCode ORDER BY TotalSales) [group_in_dense_rank],
		ROW_NUMBER() OVER(PARTITION BY ZipCode ORDER BY TotalSales) [grop_in_row_number],
		ROW_NUMBER() OVER( ORDER BY ZipCode) [row_number],
		NTILE(5) OVER(PARTITION BY ZipCode ORDER BY TotalSales) [ntile]
FROM @tempSales;

------------------------------------------------------------------------------------

/*
-----------------------------------------
	ItemId		Client		Price	Avg
-----------------------------------------
1	1			owen		100		93
2	1			orion		94		93	
3	1			marie		85		93	
4	2			owen		70		74
5	2			orion		72		74
6	2			marie		80		74	
7	3			owen		90		90	
8	3			orion		95		90
9	3			marie		85		90
-----------------------------------------
*/

--5. First 3 columns are coming from the table and 4th column is a calculated one. 

SELECT *,
	AVG(Price) OVER(PARTITION BY ItemID) AS Avg
FROM [ClientTable] --@tempTable;


--6.

--TRUNCATE: Remove all records from a table permanently

--Take a copy table from [ClientTable]
SELECT * INTO copytable1
FROM [ClientTable];

SELECT * 
FROM  copytable1;

TRUNCATE TABLE copytable1;

SELECT * 
FROM  copytable1;

--DELETE: It is used to delete exiting records from an existing table.

--Take a copy table from [ClientTable]
SELECT * INTO copytable2
FROM [ClientTable];

SELECT * 
FROM  copytable2;

DELETE FROM copytable2  --remove records by condition
WHERE Price <80;

SELECT * 
FROM  copytable2;

DELETE FROM copytable2; --remove all records

SELECT * 
FROM  copytable2;
--DROP: Delete objects from the database;

--Take a copy table from [ClientTable]
SELECT * INTO copytable3
FROM [ClientTable];

SELECT * 
FROM  copytable3;

DROP TABLE copytable3;

SELECT * 
FROM  copytable3; --ERROR: give invalid object name

--7.Write a basic SQL query that lists all orders with customer information.
--We have two tables; order and customer that contain the following columns.
/*
--------------------------------------------------------
OrderId		CustomerID		OrderNumber		TotalAmount
--------------------------------------------------------
1			1				12AB			5		
2			1				34ED			6
3			2				4567YHN			9	
--------------------------------------------------------

--------------------------------------------------------
CustomerID	FirstName	LastName	City		Country
--------------------------------------------------------
1			Diana		Cece		Toronto		Canada
2			Adam		Honour		Istanbul	Turkey
--------------------------------------------------------
*/

--Create Order table
DECLARE @tempOrder TABLE (OrderID INT, CustomerID INT, OrderNumber VARCHAR(10), TotalAmount INT)
INSERT @tempOrder VALUES (1, 1, '12AB', 5),
						 (2, 1, '34ED', 6),
						 (3, 2, '4567YHN', 9);
SELECT * INTO [Order] FROM @tempOrder;

--Create Customer table
DECLARE @tempCustomer TABLE (CustomerID INT, FirstName VARCHAR(20), LastName VARCHAR(20), City VARCHAR(20), Country VARCHAR(20) )
INSERT @tempCustomer VALUES (1, 'Diana', 'Cece', 'Toronto', 'Canada'),
							(2, 'Adam', 'Honour', 'Istanbul', 'Turkey')
SELECT * INTO [Customer] FROM @tempCustomer;


SELECT OrderID, OrderNumber, TotalAmount, o.CustomerID, FirstName, LastName, City, Country
FROM [Order] o
	LEFT JOIN Customer c ON o.CustomerID = c.CustomerID;


------------------------------------------------------------------------------------------

--8. Print the rows which have 'Yellow' in one of columns C1, C2, or C3, but without using OR.
/*
---------------------------------------
Id		C1			C2			C3
---------------------------------------
1		Red			Yellow		Blue
2		NULL		Red			Green
3		Yellow		NULL		Violet	
---------------------------------------
*/

--Create color table
DECLARE @tempColor TABLE (ID INT, C1 VARCHAR(10), C2 VARCHAR(10), C3 VARCHAR(10))
INSERT @tempColor VALUES (1, 'Red', 'Yellow', 'Blue'),
						(2, NULL, 'Red','Green'),
						(3, 'Yellow', NULL, 'Violet')
SELECT * INTO [color] 
FROM @tempColor;

SELECT * FROM [color]
WHERE C1 ='Yellow'
UNION
SELECT * FROM [color]
WHERE C2 ='Yellow'
UNION
SELECT * FROM [color]
WHERE C2 ='Yellow';

--unsolve pivot
SELECT ID, color_name, color_type
FROM [color]
UNPIVOT
(
color_name FOR color_type In (C1, C2,  C3)
) unpvt
WHERE color_name= 'Yellow';



--alternative way
SELECT * 
FROM [color]
WHERE ID IN (
			SELECT ID
			FROM [color]
			UNPIVOT
			(
			color_name FOR color_type In (C1, C2,  C3)
			) unpvt
			WHERE color_name= 'Yellow'
			)

--alternative way
SELECT DISTINCT color.*
FROM [color] 
	CROSS APPLY (VALUES (C1), (C2), (C3)) AS color_type(color_name)
WHERE color_type.color_name = 'Yellow';


--alternative way
SELECT *
FROM [color]
WHERE (CASE WHEN C1 = 'Yellow' THEN 1 WHEN C2 = 'Yellow' THEN 1 WHEN C3 = 'Yellow' THEN 1 ELSE 0 END ) > 0
   

--Unwanted way
SELECT *
FROM ( 
	SELECT *
	FROM [color]
	WHERE C1 ='Yellow' OR C2 ='Yellow' OR C3 ='Yellow'
) subq;


------------------------------------------------------------------------------------------
/*
customer_table
--------------------------------------------------
id		first_name		last_name		birth_date
--------------------------------------------------
1		Edward			Smith			5.12.1981
2		Bety			Lake			14.07.1986
3		Kathie			Snow			20.11.1992
4		Robert			Myres			1.01.1990
--------------------------------------------------

order_table
--------------------------------------------------
ord_id		cust_id		ord_date	prod_id
--------------------------------------------------
1			3			1.01.2022	10	
2			2			1.01.2022	11
3			3			2.01.2022	12
4			4			3.01.2022	13
--------------------------------------------------
*/
--9. Write the result values that will return when the following query runs.

--Create customer_table
DECLARE @customer_table TABLE (id INT, first_name VARCHAR(20), last_name VARCHAR(20), birth_date DATE)
INSERT @customer_table VALUES	(1, 'Edward', 'Smith', '1981-12-5'),
								(2, 'Bety', 'Lake','1986-07-14'),
								(3, 'Kathie', 'Snow', '1992-11-20'),
								(4, 'Robert', 'Myres', '1990-01-01')
SELECT * INTO customer_table FROM @customer_table;

--Create order_table
DECLARE @order_table TABLE (ord_id INT, cust_id INT, ord_date DATE, prod_id INT)
INSERT @order_table VALUES  (1, 3, '2022-01-01', 10),
							(2, 2, '2022-01-01', 11),
							(3, 3, '2022-01-02', 12),
							(4, 4, '2022-01-03', 13)
SELECT * INTO order_table FROM @order_table;


SELECT first_name, last_name
FROM customer_table AS A
WHERE NOT EXISTS (
					SELECT *
					FROM order_table AS B
					WHERE ord_date >='2022-01-02'
					AND B.cust_id = A.id				
				)
------------------------------------------------------------------------------------

/*
customer_table
--------------------------------------------------
id		first_name		last_name		birth_date
--------------------------------------------------
1		Edward			Smith			5.12.1981
2		Bety			Lake			14.07.1986
3		Kathie			Snow			20.11.1992
4		Robert			Myres			1.01.1990
--------------------------------------------------

order_table
--------------------------------------------------
ord_id		cust_id		ord_date	prod_id
--------------------------------------------------
1			3			1.01.2022	10	
2			2			1.01.2022	11
3			3			2.01.2022	12
4			4			3.01.2022	13
--------------------------------------------------
*/
--10. Write the query using EXCEPT which will give the same result as the query below. 

SELECT first_name, last_name
FROM customer_table AS A
WHERE NOT EXISTS (SELECT 1 FROM order_table B					
					WHERE ord_date >= '2022-01-02' AND B.cust_id = A.id
					);

					
--first way
SELECT first_name, last_name
FROM customer_table
EXCEPT
SELECT c.first_name, c.last_name
FROM customer_table AS c
	INNER JOIN order_table AS o ON c.id = o.cust_id
WHERE o.ord_date >= '2022-01-02';




--alternative way
WITH CTE AS
(
SELECT id, first_name, last_name, ord_id, ord_date, prod_id
FROM customer_table c
	LEFT JOIN order_table o ON c.id = o.cust_id
)
SELECT first_name, last_name
FROM CTE
WHERE id NOT IN (SELECT id
					FROM CTE
					WHERE ord_date >= '2022-01-02');					

--alternative way
WITH CTE AS
(
SELECT id
FROM customer_table
EXCEPT 
SELECT cust_id
FROM order_table
WHERE ord_date > = '2022-01-02'
)
SELECT first_name, last_name
FROM customer_table c
	INNER JOIN CTE ON c.id = CTE.id;

--alternative way
WITH CTE AS
(
SELECT DISTINCT id, c.first_name, c.last_name, ord_date
FROM customer_table AS c
	LEFT JOIN order_table AS o ON c.id = o.cust_id
), CTE2 AS
(
SELECT first_name, last_name
FROM CTE
EXCEPT
SELECT first_name, last_name
FROM CTE
WHERE ord_date >= '2022-01-02'
)
SELECT *
FROM CTE2;

