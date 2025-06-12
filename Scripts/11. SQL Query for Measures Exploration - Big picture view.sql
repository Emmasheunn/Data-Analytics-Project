/*
-------------------------------------------------------------
 Measures Exploration - Big Numbers
-------------------------------------------------------------
This script alters first the data types of the TotalAmount
and Price columns into a type Float fit for calculations.
It also Aggregates the measures and provides a big picture
view of the whole dataset.
*/

-- Altering column data types for easier manipulations
ALTER TABLE silver.fact_Orders
ALTER COLUMN TotalAmount FLOAT;

ALTER TABLE silver.dim_Products
ALTER COLUMN Price FLOAT;

-- Find the Total sales amount
SELECT
	'Total Sales Amount' AS Agg_Name, 
	ROUND(SUM(TotalAmount),2) AS AggregationValue
FROM silver.fact_Orders
-- Find how many items are sold
UNION ALL
SELECT
	'Total Quantities Sold',
	SUM(Quantity)
FROM silver.fact_Orders
-- Find the average price of products
UNION ALL
SELECT
	'Average Price Of Products',
	ROUND(AVG(Price),2)
FROM silver.dim_Products
-- Find the total number of orders including cases
-- where an order contains multiple products
UNION ALL
SELECT 
	'Total Nr of Orders', 
	COUNT(DISTINCT OrderID)
FROM silver.fact_Orders
UNION ALL
-- Find the total number of products
SELECT 
	'Total Nr of Products',
	COUNT(ProductID)
FROM silver.dim_Products
-- Find the total number of customers
UNION ALL
SELECT 
	'Total Nr of Customers',
	COUNT(CustomerID)
FROM silver.dim_Customers
-- Find the total number of customers that have placed an order
UNION ALL
SELECT 
	'Total Nr of Ordering Customers',
	COUNT(DISTINCT CustomerID) 
FROM silver.fact_Orders