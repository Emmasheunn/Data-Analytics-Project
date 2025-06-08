/*
--------------------------------------------------------
Create Tables for import of source table
----------------------------------------------------------
*/
/* Objective:
This script helps create the bronze layer tables (customers, orders and products)
that mirror the structure of the source tables for easy import of data.
The structure and data type of each column was determined
 after careful analysis of source's tables and data fields.
*/
CREATE TABLE bronze.stg_customers (
CustomerID NVARCHAR(10),
FirstName NVARCHAR(50),
Email NVARCHAR(100),
City VARCHAR(20),
State CHAR(2),
SignupDate NVARCHAR(50)
);
CREATE TABLE bronze.stg_orders (
OrderID NVARCHAR(20),
CustomerID NVARCHAR(50),
ProductID NVARCHAR(20),
OrderDate NVARCHAR (50),
Quantity INT,
TotalAmount NVARCHAR(20)
);
CREATE TABLE bronze.stg_products (
ProductID NVARCHAR(20),
ProductName VARCHAR(50),
Category VARCHAR(50),
Price NVARCHAR(20)
);