/*
-------------------------------------------------
Advanced Analytics
-------------------------------------------------
Objective:
This script performs various sorts of analysis on the 
cleaned datasets, creates customer and products segments, 
and redefines column datatypes in order to ease analysis.
Analysis carried out include:
-- Change-Over-Time
-- Cummulative Analysis
-- Performance Analysis
-- Part-To-Whole Analysis
-- Data Segmentation
*/
-- 1. Change-Over-Time
-- Setting OrderDate column to Date Type
--ALTER TABLE silver.fact_Orders
--ALTER COLUMN OrderDate DATE
-- Sum of sales, Avg of sales, Nr of Customers by Year, Month and Quarter
SELECT
	YEAR(OrderDate) AS Year,
	SUM(TotalAmount) SalesByYear,
	AVG(TotalAmount) AvgSalesByYear,
	COUNT(CustomerID) NrOfCustomers
FROM silver.fact_Orders
GROUP BY YEAR(OrderDate)
ORDER BY Year;

SELECT
	MONTH(OrderDate) AS Month,
	SUM(TotalAmount) SalesByMonth,
	AVG(TotalAmount) AS AvgSalesByMonth,
	COUNT(CustomerID) NrOfCustomers
FROM silver.fact_Orders
GROUP BY MONTH(OrderDate)
ORDER BY Month;

SELECT
	DATEPART(Quarter, OrderDate) AS Quarter,
	SUM(TotalAmount) SalesByQuarter,
	AVG(TotalAmount) AS AvgSalesByQuarter,
	COUNT(CustomerID) NrOfCustomers
FROM silver.fact_Orders
GROUP BY DATEPART(Quarter, OrderDate)
ORDER BY Quarter;

SELECT
	DATETRUNC(MONTH,OrderDate) AS Month,
	SUM(TotalAmount) SalesByMonth,
	AVG(TotalAmount) AS AvgSalesByMonth,
	COUNT(CustomerID) NrOfCustomers
FROM silver.fact_Orders
GROUP BY DATETRUNC(MONTH,OrderDate)
ORDER BY DATETRUNC(MONTH,OrderDate)


-- 2. Cummulative Analysis
SELECT 
	Month,
	CummulativeSalesByMonth,
	SUM(CummulativeSalesByMonth) OVER (ORDER BY Month)
FROM (
	SELECT
		DATETRUNC(MONTH,OrderDate) AS Month,
		SUM(TotalAmount) CummulativeSalesByMonth
	FROM silver.fact_Orders
	GROUP BY DATETRUNC(MONTH,OrderDate)
	)t

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
	)t

-- 6 Months Moving Average
SELECT 
	Month,
	CummulativeSalesByMonth,
	AVG(CummulativeSalesByMonth) OVER (ORDER BY Month 
	ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) SixMnthsMovingAvg
FROM (
	SELECT
		DATETRUNC(MONTH,OrderDate) AS Month,
		SUM(TotalAmount) AS CummulativeSalesByMonth
	FROM silver.fact_Orders
	GROUP BY DATETRUNC(MONTH,OrderDate)
	)t

-- 3. Performance Analysis
/* Analyze the yearly performance of products by comparing
each product's sales to both its average sales performance 
and the previous year's sales
*/
SELECT
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
		GROUP BY YEAR(OrderDate), ProductID)t

-- 4. Part-To-Whole Analysis
-- What's the contribution of each category to overall sales?
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
GROUP BY Prd.Category)t

-- 5. Data Segmentation
/* Segment products into cost ranges and count 
how many products fall into each segment */
WITH CTE_Segment AS (
SELECT 
	ProductID,
	Price,
	CASE 
		WHEN Price >= 400 THEN 'Luxury'
		WHEN Price >= 100 ANd Price < 400 THEN 'Decent'
		ELSE 'Cheap'
	END AS PriceRange
FROM silver.dim_Products)
SELECT 
	PriceRange,
	COUNT(ProductID) AS NrOfProducts
FROM CTE_Segment
GROUP BY PriceRange
-- Segment customers by spending behaviour and count 
-- how many customers fall in each category
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
GROUP BY CustomerSegment