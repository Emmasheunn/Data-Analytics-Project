/*
----------------------------------------------------------------- 
Data Exploration - bronze.stg_customers
-----------------------------------------------------------------
Objective:
This script helps check for and identify data quality issues 
in the customers table.
*/
-- Checks for NULLS in primary key
SELECT 
	CustomerID,
	COUNT(*) AS Checks
FROM bronze.stg_customers
GROUP BY CustomerID
HAVING COUNT(*) > 1 OR CustomerID IS NULL;

-- Check string values for unwanted spaces
SELECT FirstName
FROM bronze.stg_customers
WHERE FirstName != TRIM(FirstName);

SELECT LastName
FROM bronze.stg_customers
WHERE LastName != TRIM(LastName);

SELECT Email
FROM bronze.stg_customers
WHERE Email != TRIM(Email);

SELECT State
FROM bronze.stg_customers
WHERE State != TRIM(State);

-- Checking for data inconsistencies in categorical columns
SELECT DISTINCT
	City
FROM bronze.stg_customers;

SELECT DISTINCT
	State
FROM bronze.stg_customers;

-- Checks date inconsistencies
SELECT 
	*
FROM bronze.stg_customers
WHERE ISDATE(Signupdate) = 0;

