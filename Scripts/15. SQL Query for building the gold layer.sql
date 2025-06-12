/*
------------------------------------------------------
Building the Gold Layer.
------------------------------------------------------
Objective:
This script finalizes the silver layer by joining all
dimension tables together with the fact table.
This script also assigns the primary key for each
table to facilitate effortless joins.
This script also creates the VIEWS for further analysis 
in visualization tools like Power BI and Tableau.
*/
-- Assigning Primary key to column
ALTER TABLE silver.dim_Customers
ALTER COLUMN CustomerID nvarchar(10) NOT NULL;
ALTER TABLE silver.dim_Customers
ADD CONSTRAINT PK_dim_Customers_CustomerID PRIMARY KEY (CustomerID);

ALTER TABLE silver.fact_Orders
ALTER COLUMN OrderID nvarchar(10) NOT NULL;
ALTER TABLE silver.fact_Orders
ADD CONSTRAINT PK_fact_Orders_OrderID PRIMARY KEY (OrderID);

ALTER TABLE silver.dim_Products
ALTER COLUMN ProductID nvarchar(10) NOT NULL;
ALTER TABLE silver.dim_Products
ADD CONSTRAINT PK_dim_Products_ProductID PRIMARY KEY (ProductID);
-- Creating VIEW for Reporting in gold Schema
CREATE VIEW gold.SalesData AS
SELECT 
	Cus.CustomerID,
	Cus.FirstName,
	Cus.LastName,
	Cus.State,
	Cus.SignupDate,
	Ord.OrderID,
	Ord.ProductID,
	Ord.Quantity,
	Prd.Price,
	Ord.TotalAmount,
	Ord.OrderDate,
	Prd.ProductName,
	Prd.Category AS ProductCategory
FROM silver.fact_Orders AS Ord
LEFT JOIN silver.dim_Products AS Prd
ON Ord.ProductID = Prd.ProductID
LEFT JOIN silver.dim_Customers AS Cus
ON Ord.CustomerID = Cus.CustomerID;

-- 1. Sum of sales, Avg of sales, Nr of Customers by Year, Month and Quarter
CREATE VIEW gold.SalesByYear AS
SELECT
	DATETRUNC(YEAR,OrderDate) AS Year,
	SUM(TotalAmount) SalesByYear,
	AVG(TotalAmount) AS AvgSalesByYear,
	COUNT(CustomerID) NrOfCustomers
FROM silver.fact_Orders
GROUP BY DATETRUNC(Year,OrderDate);


CREATE VIEW gold.SalesByMonth AS
SELECT
	DATETRUNC(MONTH,OrderDate) AS Month,
	SUM(TotalAmount) SalesByMonth,
	AVG(TotalAmount) AS AvgSalesByMonth,
	COUNT(CustomerID) NrOfCustomers
FROM silver.fact_Orders
GROUP BY DATETRUNC(MONTH,OrderDate);


-- 2. Cummulative Analysis
CREATE VIEW gold.RunningTotal AS
SELECT 
	Year,
	CummulativeSalesByYear,
	SUM(CummulativeSalesByYear) OVER (ORDER BY Year) RunningTotal
FROM (
	SELECT
		DATETRUNC(YEAR,OrderDate) AS Year,
		SUM(TotalAmount) CummulativeSalesByYear
	FROM silver.fact_Orders
	GROUP BY DATETRUNC(YEAR,OrderDate)
	)t;


-- 3. Performance Analysis

CREATE VIEW gold.PerformanceAnalysis AS SELECT
	ProductID,
	Year,
	TotalSales,
	LAG(TotalSales) OVER (PARTITION BY ProductID ORDER BY Year) PrevYearSales,
	Avg(TotalSales) OVER (PARTITION BY ProductID) AvgSalesPerYear,
	TotalSales - LAG(TotalSales) OVER (PARTITION BY ProductID ORDER BY Year) Growth,
	TotalSales - Avg(TotalSales) OVER (PARTITION BY ProductID) AvgCompared
FROM(
		SELECT 
			ProductID,
			YEAR(OrderDate) Year,
			SUM(TotalAmount) TotalSales
		FROM silver.fact_Orders
		GROUP BY YEAR(OrderDate), ProductID)t;

-- 4. Part-To-Whole Analysis

CREATE VIEW gold.PartToWholeAnalysis AS
SELECT 
	Category,
	SumOfSales,
	CONCAT(ROUND(SumOfSales/SUM(SumOfSales) OVER () * 100, 2), '%') ContrInPercent
FROM
(SELECT
	Prd.Category,
	SUM(Ord.TotalAmount) SumOfSales
FROM silver.dim_Products Prd
JOIN silver.fact_Orders Ord
ON Prd.ProductID = Ord.ProductID
GROUP BY Prd.Category)t;

-- 5. Customer Segmentation


CREATE VIEW gold.CustomerSegment AS 
SELECT 
	CustomerSegment,
	COUNT(*) NrOfCustomers
FROM(
	SELECT 
	CustomerID,
	CASE 
		WHEN SUM(TotalAmount) >= 10000 THEN 'Platinum'
		WHEN SUM(TotalAmount) >= 5000 THEN 'Gold'
		WHEN SUM(TotalAmount) >= 1000 THEN 'Silver'
		ELSE 'Bronze'
	END AS CustomerSegment
FROM silver.fact_Orders
GROUP BY CustomerID)t
GROUP BY CustomerSegment;