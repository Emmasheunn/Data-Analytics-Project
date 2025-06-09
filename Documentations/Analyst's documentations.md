# Data Exploration
## Analyzing source tables.

### For bronze.stg_customers table.
- Primary key is CustomerID.
- Found 125 duplicates in primary key, dropped all 125 as they had the same details across all columns, must have been entered twice into the table.
- No null primary keys found.
- Flagged customers with neither LastNames nor FirstNames in Email as 'N/A'.(117 cases)
- Created new Email field using the FirstName, LastName and number in CustomerID.
- Fixed Date Formats inconsistencies.
- Found 523 nulls in FirstName column
- Found 117 customers with no names at all.

### For bronze.stg_orders table.
- Primary key is OrderID
- It also has foreign keys: CustomerID, ProductID
- Found 90 duplicates in primary key,dropped all 90 as they had the same details across all columns, must have been entered twice into the table.
- No NULL foreign keys found.
- Validated foreign keys with Customers and Products table.
- Fixed inconsistencies and handled NULLS in OrderDate column.
- Found No NULL or 0 Quantities.
- Found 161 orders with Negative values, Dropped all 161 orders as there were no basis on what to replace them with. The TotalAmount column does not help either, so dropping these rows helps clean up my TotalAmount column as well.
- Joined Price column from the products table in order to recalculate TotalAmount.
- Recalculated TotalAmount as Quantity × Price
- Dropped all orders that don't have a price as there were no basis to fill their prices in with average or median; the category had various products with the same name.

### For bronze.stg_products table.
- Primary key is ProductID
- Found 100 duplicates in Primary key, dropped all 100 entries as they were also entered twice.
- Found 212 products with NULL names, set all to "Unknown Product" according to project requirements.
- Re-categorized Category column into "Electronics", "Home Appliance", and  "Tools".
- Found 116 products with non-numeric values, dropped all 116 according to project requirements.
- No negative values found in Price column.
