/*
-----------------------------------------------------------------
Data Cleansing - Orders Table
-----------------------------------------------------------------
Objective:
This scripts handles all nulls according to project requirements.
These fixes were effected only after careful checks on each column.
Fixes include:
- Handling duplicate values in Primary key
- Drop nonsensical values in measure columns
- Cleaned Price column from products table
- Recalculated TotalAmount column with price from products table
- Handling date format inconsistencies
- Handling NULLS
The cleaned table is then inserted into the silver.Orders table.
*/

wITH CTE_Cleaned AS 
(	SELECT 
		OrderID,
		CustomerID,
		ProductID,
		OrderDate,
		Quantity,
		TotalAmount
	FROM 
	(
			SELECT 
				OrderID,
				CustomerID,
				ProductID,
				-- Fixing date inconsistencies and handling nulls
				CASE 
					WHEN ISDATE(OrderDate) = 1 THEN CAST(OrderDate AS DATE)
					WHEN OrderDate IS NULL THEN CAST('1900-01-01' AS DATE)
					WHEN ISDATE(CONCAT(RIGHT(OrderDate,4),'-',
						SUBSTRING(OrderDate,4,2),'-',LEFT(OrderDate,2))) = 1 THEN 
						CAST(CONCAT(RIGHT(OrderDate,4),'-',
						SUBSTRING(OrderDate,4,2),'-',LEFT(OrderDate,2)) AS DATE)
					ELSE CAST('2055-01-01' AS DATE)
				END AS OrderDate,
				Quantity,
				TotalAmount
			FROM (
				SELECT 
					*,
					ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY OrderID) AS number
				FROM bronze.stg_orders)t
			WHERE number = 1 -- Fixing duplicates in Primary Key by selecting only distinct OrderID
	)t
	WHERE Quantity > 0		-- Fixing Quantity and TotalAmount columns by dropping 
							-- orders with negative values and TotalAmounts that are not numbers
),
CTE_PriceFromProducts AS (
	SELECT 
		ProductID,
		Price
	FROM bronze.stg_products
	WHERE Price != 'invalid'
),
 CTE_Collect AS (
	SELECT distinct
		CO.OrderID,
		CO.CustomerID,
		CO.ProductID,
		CO.OrderDate,
		CO.Quantity,
	-- Recalculating TotalAmount AS Quantity * Price and casting back to NVARCHAR to fit silver layer table
		CAST(ROUND(CAST(CO.Quantity AS float) * CAST(P.Price AS float),2) AS NVARCHAR) AS TotalAmount
	FROM CTE_Cleaned AS CO
	 LEFT JOIN CTE_PriceFromProducts AS P
	ON P.ProductID = CO.ProductID
	-- Dropping all orders that don't have a price
	WHERE P.Price IS NOT NULL
)

	-- Collecting all cleaned columns
INSERT INTO silver.Orders (
							OrderID,
							CustomerID,
							ProductID,
							OrderDate,
							Quantity,
							TotalAmount
						  )

	SELECT 
		OrderID,
		CustomerID,
		ProductID,
		OrderDate,
		Quantity,
		TotalAmount
	FROM CTE_Collect

-- Checking if data quality fixes were effective in silver layer
SELECT *
FROM
	(SELECT 
		*,
		ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY OrderID) AS counts
	FROM silver.Orders)t
WHERE counts > 1 OR OrderID IS NULL;

-- Checking foreign key for nulls
SELECT * FROM silver.Orders
WHERE CustomerID IS NULL;

SELECT * FROM silver.Orders
WHERE ProductID IS NULL;

-- Checking OrderDate column for date inconsistencies
SELECT 
	OrderDate,
	ISDATE(OrderDate) AS verify
FROM silver.Orders;

-- Checking for nonsensical values in quantity field
SELECT * FROM silver.Orders
WHERE Quantity < 1
