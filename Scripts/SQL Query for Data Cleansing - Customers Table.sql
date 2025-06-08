/*
-----------------------------------------------------------------
Data Cleansing - Customers Table
-----------------------------------------------------------------
Objective:
This scripts handles all nulls according to project requirements.
These fixes were effected only after careful checks on each column.
Fixes include:
- Handling duplicate values in Primary key
- Deriving new Email column from names and CustomerID
- Handling date format inconsistencies
- Handling NULLS
The cleaned table is then inserted into the silver.Customers table.
*/

-- Wrapping all fixed issues in a CTE
WITH CTE_Customers AS
(
SELECT 
	CustomerID,
	FirstName,
	LastName,
-- Fix emails according to business rules
	CASE 
		WHEN FirstName IS NOT NULL AND LastName IS NOT NULL 
			THEN CONCAT(FirstName,LastName,CAST(CAST(RIGHT(CustomerID,5) AS INT) AS varchar),'@cuzies.org')
		WHEN FirstName IS NULL AND LastName IS NOT NULL 
			THEN CONCAT(LastName,CAST(CAST(RIGHT(CustomerID,5) AS INT) AS varchar),'@cuzies.org')
		WHEN FirstName IS NOT NULL AND LastName IS NULL 
			THEN CONCAT(FirstName,CAST(CAST(RIGHT(CustomerID,5) AS INT) AS varchar),'@cuzies.org')
		ELSE 'N/A'
	END AS Email,
-- Fixing City NULL values
	CASE WHEN City IS NULL THEN 'Unknown'
		 ELSE City
	END AS City,
	State,
-- Fixing date inconsistencies
	CASE 
		WHEN ISDATE(Signupdate) = 1 THEN CAST(Signupdate AS DATE)
		WHEN Signupdate IS NULL THEN CAST('1900-01-01' AS DATE)
		WHEN ISDATE(CONCAT(RIGHT(Signupdate,4),'-',
			SUBSTRING(Signupdate,4,3),LEFT(Signupdate,2))) = 1 THEN 
			CAST(CONCAT(RIGHT(Signupdate,4),'-',
			SUBSTRING(Signupdate,4,3),LEFT(Signupdate,2)) AS DATE)
		ELSE CAST('2055-01-01' AS DATE)
	END AS Signupdate
FROM (
	SELECT
-- Fixing duplicates in Primary key
		CustomerID,
		FirstName,
		LastName,
		Email,
		City,
		State,
		Signupdate,
		ROW_NUMBER() OVER (PARTITION BY CustomerID 
		ORDER BY CustomerID) AS flag
	FROM bronze.stg_customers)t
	WHERE flag = 1
)
-- Collecting all cleaned columns
INSERT INTO silver.Customers (
						CustomerID,
						FirstName,
						LastName,
						Email,
						City,
						State,
						Signupdate)
SELECT
		CustomerID,
		FirstName,
		LastName,
		Email,
		City,
		State,
		Signupdate
FROM CTE_Customers
ORDER BY Signupdate DESC;

-- Verify data in silver layer
SELECT 
	CustomerID,
	FirstName,
	LastName,
	Email,
	City,
	State,
	Signupdate
FROM silver.Customers;
