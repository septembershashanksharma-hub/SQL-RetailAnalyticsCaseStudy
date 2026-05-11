ALTER TABLE sales_transaction
RENAME COLUMN ï»¿TransactionID to TransactionID;

ALTER TABLE customer_profiles
RENAME COLUMN ï»¿CustomerID to CustomerID;

ALTER TABLE product_inventory
RENAME COLUMN ï»¿ProductID to ProductID;


# Write a query to identify the number of duplicates in "sales_transaction" table. Also, create 
# a separate table containing the unique values and remove the original table from the databases 
# and replace the name of the new table with the original name.

SELECT * 
FROM sales_transaction;

SELECT TransactionID, COUNT(*)
FROM sales_transaction
GROUP BY TransactionID
HAVING COUNT(*)>1;


CREATE TABLE sales_transation_II
AS (SELECT DISTINCT TransactionID, CustomerID, ProductID, QuantityPurchased, TransactionDate, Price
FROM sales_transaction);

SELECT TransactionID, COUNT(*)
FROM sales_transation_ii
GROUP BY TransactionID
HAVING COUNT(*)>1;

DROP TABLE sales_transaction;

# Write a query to identify the discrepancies in the price of the 
# same product in "sales_transaction" and "product_inventory" tables. 
# Also, update those discrepancies to match the price in both the tables.


SELECT *
FROM sales_transation_ii S
LEFT JOIN product_inventory P ON S.ProductID = P.ProductID
WHERE S.Price <> P.Price;

SET SQL_SAFE_UPDATES = 0;

UPDATE sales_transation_ii
SET Price = 93.12
WHERE Price = 9312;

ALTER TABLE sales_transation_ii RENAME TO sales_transaction;

SELECT *
FROM sales_transaction S
LEFT JOIN product_inventory P ON S.ProductID = P.ProductID;


# Write a SQL query to identify the null values in the dataset and replace those by “Unknown”.


SELECT *
FROM customer_profiles   #No NULLS here
WHERE Age IS NULL;

SELECT *
FROM customer_profiles   #No NULLS here
WHERE Gender IS NULL;

SELECT *
FROM customer_profiles   #No NULLS here
WHERE JoinDate IS NULL;

SELECT *
FROM customer_profiles   #NULLS here!!
WHERE Location IS NULL;

SELECT COUNT(*)
FROM customer_profiles    #NULLS here!!
WHERE Location IS NULL;

UPDATE customer_profiles
SET Location = 'Unknown'
WHERE Location IS NULL;

SELECT *
FROM customer_profiles;

# Write a SQL query to summarize the total sales and quantities sold per product by the company.

SELECT *
FROM product_inventory;

SELECT *
FROM sales_transaction;

SELECT *
FROM sales_transaction S 
LEFT JOIN product_inventory P ON S.ProductID = P.ProductID;

SELECT P.ProductID, SUM(S.QuantityPurchased) AS TotalUnitsSold, SUM(S.QuantityPurchased * S.Price) AS TotalSales
FROM sales_transaction S 
LEFT JOIN product_inventory P ON S.ProductID = P.ProductID
GROUP BY P.ProductID
ORDER BY SUM(S.QuantityPurchased * S.Price) DESC;

#Now we know that the Product with ProductID = 17 is the best selling product

#Write a SQL query to count the number of transactions per customer to understand purchase frequency.


SELECT CustomerID, COUNT(TransactionID) AS NumberOfTransactions
FROM sales_transaction
GROUP BY CustomerID
ORDER BY COUNT(TransactionID) DESC;

#Write a SQL query to evaluate the performance of the product categories based on the total sales which
#help us understand the product categories which needs to be promoted in the marketing campaigns.

SELECT P.Category, SUM(S.QuantityPurchased) AS TotalUnitsSold, SUM(S.QuantityPurchased * S.Price) AS TotalSales
FROM sales_transaction S 
LEFT JOIN product_inventory P ON S.ProductID = P.ProductID
GROUP BY P.Category
ORDER BY SUM(S.QuantityPurchased * S.Price) DESC;

#Write a SQL query to find the top 10 products with the highest total sales revenue from the sales transactions. 
#This will help the company to identify the High sales products which needs to be focused to increase the revenue of the company.

SELECT P.ProductID,  SUM(S.QuantityPurchased * S.Price) AS TotalRevenue
FROM sales_transaction S 
LEFT JOIN product_inventory P ON S.ProductID = P.ProductID
GROUP BY P.ProductID
ORDER BY SUM(S.QuantityPurchased * S.Price) DESC
LIMIT 10;

#Write a SQL query to identify the sales trend to understand the revenue pattern of the company.

SELECT DATE_FORMAT(TransactionDate, '%Y-%m-%d') AS DATETRANS,
       COUNT(TransactionID) AS TransactionCount, 
	   SUM(QuantityPurchased) AS TotalUnitsSold,
       SUM(QuantityPurchased * Price) AS TotalSales
FROM sales_transaction
GROUP BY DATE_FORMAT(TransactionDate, '%Y-%m-%d')
ORDER BY DATE_FORMAT(TransactionDate, '%Y-%m-%d') DESC;


#Write a SQL query to understand the month on month growth rate of sales of the company which will help understand 
#the growth trend of the company.

WITH tble AS
(
SELECT MONTH(TransactionDate) AS month, SUM(QuantityPurchased * Price) AS total_sales
FROM sales_transaction
GROUP BY MONTH(TransactionDate)
)

SELECT month, total_sales, 
       LAG(total_sales) OVER() AS previous_months_sales,
       (total_sales - LAG(total_sales) OVER())
       /
       LAG(total_sales) OVER() * 100
       AS mom_growth_percentage
FROM tble;

#Write a SQL query that describes the number of transaction along with the total amount spent by each customer 
#which are on the higher side and will help us understand the customers who are the high frequency purchase customers in the company.

SELECT CustomerID, COUNT(TransactionID) AS NumberOfTransactions,
            SUM(QuantityPurchased * Price) AS TotalSpent
FROM sales_transaction
GROUP BY CustomerID
HAVING COUNT(TransactionID)>10 
              AND
              SUM(QuantityPurchased * Price) > 1000 
ORDER BY SUM(QuantityPurchased * Price) DESC;


#Write a SQL query that describes the duration between the first and the last purchase of the customer in that 
#particular company to understand the loyalty of the customer.

SELECT *, timestampdiff(DAY, FirstPurchase, LastPurchase) AS DaysBetweenPurchases
FROM
(
WITH tble AS
( SELECT CustomerID, TransactionDate,
	     row_number()OVER(PARTITION BY CustomerID ORDER BY TransactionDate) AS rnk,
         row_number()OVER(PARTITION BY CustomerID ORDER BY TransactionDate DESC) AS rnk_desc
  FROM sales_transaction
)
SELECT CustomerID, 
       MAX(CASE WHEN rnk = 1 THEN TransactionDate END) AS FirstPurchase,
       MAX(CASE WHEN rnk_desc = 1 THEN TransactionDate END) AS LastPurchase
FROM tble
GROUP BY CustomerID
) t
;

