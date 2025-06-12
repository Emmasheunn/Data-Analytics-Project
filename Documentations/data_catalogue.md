# Data Dictionary for Gold Layer
### Overview
#### The gold layer holds business-level data representation, it is structured to support analytics as reporting. It consists of Views that support further analysis is in Tableau and Power BI.

### **1. silver.dim_customers**
**Purpose:** Stores customers details enriched with geographic data 
**Columns:** 

1. CustomerID, NVARCHAR(10)
Unique identifier for each customer.
Example: "CUST00000", "CUST00001"

2. FirstName, NVARCHAR(50)
First name of the customer. May be missing in some cases.
Example: "Bob", "Alice"

3. LastName, NVARCHAR(50)
Last name of the customer. Some entries are missing.
Example: "Johnson"

4. State, CHAR(2)
US state abbreviation indicating where the customer resides.
Example: "NY", "CA", "IL"

5. SignupDate, DATE (date in "YYYY-MM-DD" format)
The date when the customer signed up or was registered.
Example: "2022-05-28", "2021-05-01"

6. OrderID, NVARCHAR(20)
Unique identifier for each order.
Example: "ORD00783", "ORD02904"


7. ProductID, NVARCHAR(20)
Unique identifier for each product.
Example: "PROD01352", "PROD00135"

8. Quantity, INT
Number of units purchased in a given order.
Example: 2, 6

9. Price, float
Price per unit of the product at the time of purchase.
Example: 435.38, 64.37

10. TotalAmount, float
Total amount paid for the order (Quantity × Price).
Example: 870.76, 2976.18

11. OrderDate, DATE (date in "YYYY-MM-DD" format)
Date when the order was placed.
Example: "2020-04-05", "2021-07-11"


12. ProductName, VARCHAR(50)
Name of the product purchased.
Example: "Widget", "Gadget", "Contraption"


13. ProductCategory, VARCHAR(50)
Category of the product.
Example: "Electronics", "Tools"
