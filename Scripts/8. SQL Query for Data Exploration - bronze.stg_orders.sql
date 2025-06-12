/*
----------------------------------------------------------------- 
Data Exploration - bronze.stg_orders
-----------------------------------------------------------------
Objective:
This script helps check for and identify data quality issues 
in the orders table.
*/
-- Checking primary key for duplicates or nulls
SELECT *
FROM
	(SELECT 
		*,
		ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY OrderID) AS counts
	FROM bronze.stg_orders)t
WHERE counts > 1 OR OrderID IS NULL;

-- Checking foreign key for nulls
SELECT * FROM bronze.stg_orders
WHERE CustomerID IS NULL;

SELECT * FROM bronze.stg_orders
WHERE ProductID IS NULL;

-- Validating foreign key with other tables
SELECT CustomerID
FROM bronze.stg_orders
WHERE NOT EXISTS (SELECT DISTINCT CustomerID
FROM bronze.stg_customers);

SELECT ProductID
FROM bronze.stg_orders
WHERE NOT EXISTS (SELECT DISTINCT ProductID
FROM bronze.stg_products);

-- Checking OrderDate column for date inconsistencies
SELECT 
	OrderDate,
	ISDATE(OrderDate) AS verify
FROM bronze.stg_orders;

-- Checking for nonsensical values in quantity field
SELECT * FROM bronze.stg_orders
WHERE Quantity < 1
