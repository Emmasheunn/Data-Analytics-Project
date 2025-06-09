/*
-----------------------------------------------------
Data Cleansing - Orders Table
-----------------------------------------------------
Objective:
This script handles data cleansing for orders based on project rules.
Fixes include:
- Removing duplicates in primary key (OrderID)
- Cleaning inconsistent date formats
- Removing invalid quantity and price values
- Recalculating TotalAmount using product prices
- Replacing NULLs with defaults
- Inserting cleaned data into silver.Orders table
*/

WITH CTE_DeduplicatedOrders AS (
    SELECT
        OrderID,
        CustomerID,
        ProductID,
        -- Fix date inconsistencies and replace NULLs with placeholders
        CASE 
            WHEN ISDATE(OrderDate) = 1 THEN CAST(OrderDate AS DATE)
            WHEN OrderDate IS NULL THEN CAST('1900-01-01' AS DATE)
            WHEN ISDATE(CONCAT(RIGHT(OrderDate,4),'-',SUBSTRING(OrderDate,4,2),'-',LEFT(OrderDate,2))) = 1 
                THEN CAST(CONCAT(RIGHT(OrderDate,4),'-',SUBSTRING(OrderDate,4,2),'-',LEFT(OrderDate,2)) AS DATE)
            ELSE CAST('2055-01-01' AS DATE)
        END AS OrderDate,
        Quantity,
        TotalAmount
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY OrderID) AS rn
        FROM bronze.stg_orders
    ) AS t
    WHERE rn = 1 AND Quantity > 0 -- Keep only the first occurrence and valid quantities
),

CTE_ValidPrices AS (
    SELECT 
        ProductID,
        CAST(Price AS FLOAT) AS Price
    FROM bronze.stg_products
    WHERE ISNUMERIC(Price) = 1
),

CTE_CleanedOrders AS (
    SELECT
        o.OrderID,
        o.CustomerID,
        o.ProductID,
        o.OrderDate,
        o.Quantity,
        -- Recalculate TotalAmount using validated price
        CAST(ROUND(o.Quantity * p.Price, 2) AS NVARCHAR) AS TotalAmount
    FROM CTE_DeduplicatedOrders o
    LEFT JOIN CTE_ValidPrices p ON o.ProductID = p.ProductID
    WHERE p.Price IS NOT NULL -- Exclude products without valid prices
)

-- Insert cleaned records into the silver layer
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
FROM CTE_CleanedOrders;

-- Post-validation checks
-- Check for duplicates or NULL OrderIDs
SELECT * FROM (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY OrderID ORDER BY OrderID) AS dup_count
    FROM silver.Orders
) AS t
WHERE dup_count > 1 OR OrderID IS NULL;

-- Check for missing foreign keys
SELECT * FROM silver.Orders WHERE CustomerID IS NULL;
SELECT * FROM silver.Orders WHERE ProductID IS NULL;

-- Validate OrderDate
SELECT OrderDate, ISDATE(OrderDate) AS is_valid_date
FROM silver.Orders;

-- Validate Quantity
SELECT * FROM silver.Orders WHERE Quantity < 1;