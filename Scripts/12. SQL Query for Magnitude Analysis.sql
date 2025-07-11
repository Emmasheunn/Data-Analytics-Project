/*
--------------------------------------------------
Magnitude Analysis
--------------------------------------------------

*/
-- Find total customers by state
SELECT 
	State,
	COUNT(CustomerID) AS CustomersByState
FROM silver.dim_Customers
GROUP BY State
ORDER BY CustomersByState DESC
-- Find total customers by city
SELECT 
	City,
	COUNT(CustomerID) AS CustomersByCity
FROM silver.dim_Customers
GROUP BY City
ORDER BY CustomersByCity DESC
-- Find Total Products by Category
SELECT 
	Category,
	COUNT(ProductID) AS ProductsByCategory
FROM silver.dim_Products
GROUP BY Category
ORDER BY ProductsByCategory DESC
-- What is the average costs in each category?
SELECT 
	Category,
	ROUND(AVG(Price),2) AS AvgPriceByCategory
FROM silver.dim_Products
GROUP BY Category
ORDER BY AvgPriceByCategory
-- What is the total revenue generated for each category?
SELECT 
	Prd.Category,
	SUM(Ord.TotalAmount) AS RevenueByCategory
FROM silver.fact_Orders Ord
LEFT JOIN silver.dim_Products Prd
ON Prd.ProductID = Ord.ProductID
GROUP BY Prd.Category
ORDER BY RevenueByCategory DESC
-- Find total revenue generated by each customer
SELECT 
	CustomerID,
	SUM(TotalAmount) AS RevenueByCustomer
FROM silver.fact_Orders
GROUP BY CustomerID
ORDER BY RevenueByCustomer DESC

-- What is the distribution of sold items across states?
SELECT 
	Cus.State,
	SUM(Ord.Quantity) AS QuantitiesByState
FROM silver.fact_Orders AS Ord
LEFT JOIN silver.dim_Customers Cus
ON Cus.CustomerID = Ord.CustomerID
GROUP BY Cus.State
ORDER BY QuantitiesByState DESC
-- Order frequency by customer
SELECT 
	CustomerID,
	COUNT(OrderID) AS OrderByCustomer
FROM silver.fact_Orders
GROUP BY CustomerID
ORDER BY OrderByCustomer DESC