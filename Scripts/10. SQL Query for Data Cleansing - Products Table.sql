/*
-----------------------------------------------------------------
Data Cleansing - Products Table
-----------------------------------------------------------------
Objective:
This scripts handles all data quality issues according to project requirements.
These fixes were effected only after careful checks on each column.
Fixes include:
- Handling duplicate values in Primary key
- Setting null values in ProductName to 'Unknown Product'
- Cleaned Price column from products table
- Recalculated TotalAmount column with price from products table
- Handling date format inconsistencies
- Handling NULLS
The cleaned table is then inserted into the silver.Orders table.
*/

WITH CTE_CleanedOrders AS (
	SELECT 
		ProductID,
		CASE 
			WHEN ProductName IS NULL THEN 'Unknown Product'
		ELSE ProductName
		END AS ProductName,
		CASE Category
			WHEN 'Gadgets' THEN 'Electronics'
			WHEN 'Toolz' THEN 'Tools'
			WHEN 'Home' THEN 'Home Appliance'
			WHEN 'Homeware' THEN 'Home Appliance'
		ELSE Category
		END AS Category,
		Price
	FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY ProductID) rn,
				ISNUMERIC(Price) AS numerical
			FROM bronze.stg_products)t
	WHERE rn = 1 -- Fixes duplicates by selectecting the first instance of the ID
	AND numerical = 1 -- Removes non-numerical rows
)

INSERT INTO silver.Products (ProductID,
							 ProductName,
							 Category,
							 Price)
SELECT
	ProductID,
	ProductName,
	Category,
	Price
FROM CTE_CleanedOrders;

-- Post-Validation checks
-- Checking primary key for duplicates
SELECT 
	ProductID,
	COUNT(*) AS counts
FROM silver.Products
GROUP BY ProductID HAVING COUNT(*) > 1;

-- Checking ProductName for NULLS and extra spaces
SELECT ProductName FROM silver.Products
WHERE ProductName IS NULL OR ProductName != TRIM(ProductName);

-- Checking category column for inconsistencies
SELECT DISTINCT Category FROM silver.Products

-- Checking Price column for non-numeric values
SELECT 
	ProductID,
	Price
FROM silver.Products
WHERE ISNUMERIC(Price) = 0
