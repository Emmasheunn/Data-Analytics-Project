/*
-----------------------------------------------------
LOAD DATA FROM FILES TO DATABASE
-----------------------------------------------------
*/
/*
Objective: This script helps insert the contents of the source CSVs 
files into the tables previously created in one go.

WARNING: The script truncates any existing table with the name provided 
and then inserts the content of the CSV files.

NOTE: The file path provided is only representative of the location 
of the CSV files on my PC at the time of execution of this project.
This result can also be achieved by using the flat file import
wizard available in the SQL Server Management Studio
*/
TRUNCATE TABLE bronze.stg_customers;

BULK INSERT bronze.stg_customers
FROM 'C:\temp\customers.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
	);

TRUNCATE TABLE bronze.stg_orders;

BULK INSERT bronze.stg_orders
FROM 'C:\temp\orders.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
	);

TRUNCATE TABLE bronze.stg_products

BULK INSERT bronze.stg_products
FROM 'C:\temp\products.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	TABLOCK
	);

/* TABLOCK Locks the table during load to improve performance
FIRSTROW SET TO 2 indicates the first row of the table starts from row 2
FIELDTERMINATOR declares the delimiterused in the document
*/
-- Verify imported data
SELECT COUNT(*) FROM bronze.stg_customers;
SELECT COUNT(*) FROM bronze.stg_orders;
SELECT COUNT(*) FROM bronze.stg_products;
