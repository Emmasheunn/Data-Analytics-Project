/*
---------------------------------------------------
Ranking Analysis - Top N Bottom N
---------------------------------------------------
*/
-- Which 5 Products generate the highest revenue
SELECT TOP 5
	ProductName,
	SUM(TotalAmount) TotalRevenue
FROM silver.fact_Orders Ord
LEFT JOIN silver.dim_Products Pro
ON Ord.ProductID = Pro.ProductID
GROUP BY Pro.ProductID, ProductName
ORDER BY TotalRevenue DESC

-- What are the 5 worst-performing products in terms of sales amount
SELECT TOP 5
	ProductName,
	SUM(TotalAmount) TotalRevenue
FROM silver.fact_Orders Ord
LEFT JOIN silver.dim_Products Pro
ON Ord.ProductID = Pro.ProductID
GROUP BY Pro.ProductID, ProductName
ORDER BY TotalRevenue

/* Show the Top 10 Customers who have generated the highest revenue
along with their details such as fullname, state and duration 
 of loyalty in months */
WITH CTE_TopCus AS
(SELECT TOP 10
			CustomerID,
			SUM(TotalAmount) AS TotalSpending,
			ROW_NUMBER() OVER (ORDER BY SUM(TotalAmount)DESC) AS Ranking
		FROM silver.fact_Orders
		GROUP BY CustomerID
		ORDER BY SUM(TotalAmount) DESC)
SELECT 
	Cus.CustomerID,
	CONCAT(Cus.FirstName, ' ' ,Cus.LastName) AS FullName,
	Cus.State,
	DATEDIFF(MONTH, Cus.SignupDate, GETDATE()) MonthsOfLoyalty,
	TC.TotalSpending,
	TC.Ranking
FROM silver.dim_Customers AS Cus
LEFT JOIN CTE_TopCus AS TC
ON TC.CustomerID = Cus.CustomerID
WHERE Cus.CustomerID IN (SELECT CustomerID FROM CTE_TopCus)
ORDER BY Ranking
-- Find the 3 Customers with the fewest orders placed.
SELECT TOP 3
	CustomerID, 
	COUNT(OrderID) NrOfOrders
FROM silver.fact_Orders
GROUP BY CustomerID
ORDER BY NrOfOrders
