/* 
----------------------------------------------
Create Database and schemas
----------------------------------------------
*/
/*
Script's Purpose:
This script helps create a new database called 'DataWarehouseAnalysis'. The script also sets up three schemas within the created database: 'bronze', 'silver', and 'gold'.
*/


-- Switching to database master
USE master;
-- Creating and switching to new Database
CREATE DATABASE DataWarehouseAnalysis;
USE DataWarehouseAnalysis;
GO
-- Creating schemas for the 3 layers
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO