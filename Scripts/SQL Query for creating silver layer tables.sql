/*
--------------------------------------------------------
Create Tables for Silver layer table
----------------------------------------------------------
*/
/* Objective:
This script helps create the silver layer tables (Customers, Orders and Products)
that follows the naming convention stated in the project requirements.
The structures and datas type of the columns are unchanged as indicated 
in the warehouse architecture diagram.
*/
;CREATE TABLE silver.dim_Customers (
		CustomerID NVARCHAR(10),
		FirstName NVARCHAR(50),
		LastName NVARCHAR(50),
		Email NVARCHAR(100),
		City VARCHAR(20),
		State CHAR(2),
		SignupDate NVARCHAR(50)
);
CREATE TABLE silver.fact_Orders (
		OrderID NVARCHAR(20),
		CustomerID NVARCHAR(50),
		ProductID NVARCHAR(20),
		OrderDate NVARCHAR (50),
		Quantity INT,
		TotalAmount NVARCHAR(20)
);
CREATE TABLE silver.dim_Products (
		ProductID NVARCHAR(20),
		ProductName VARCHAR(50),
		Category VARCHAR(50),
		Price NVARCHAR(20)
);
