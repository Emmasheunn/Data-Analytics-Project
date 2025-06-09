-- Checking primary key for duplicates
SELECT 
	ProductID,
	COUNT(*) AS counts
FROM bronze.stg_products
GROUP BY ProductID HAVING COUNT(*) > 1

-- Comparing duplicates to decide drop 
SELECT * 
FROM bronze.stg_products
WHERE ProductID IN
(SELECT n FROM (SELECT 
	ProductID n,
	COUNT(*) AS counts
FROM bronze.stg_products
GROUP BY ProductID
)t
WHERE counts > 1
);

-- Checking ProductName for NULLS and extra spaces
SELECT * FROM bronze.stg_products
WHERE ProductName IS NULL;

SELECT * FROM bronze.stg_products
WHERE ProductName != TRIM(ProductName);

-- Checking category column for inconsistencies
SELECT DISTINCT Category FROM bronze.stg_products

-- Checking Price column for non-numeric values
SELECT * FROM bronze.stg_products
WHERE ISNUMERIC(Price) = 0