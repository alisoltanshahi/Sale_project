ALTER TABLE customers
MODIFY Customer_ID VARCHAR(255) PRIMARY KEY,
MODIFY Customer_Name VARCHAR(255),
MODIFY City VARCHAR(255),
MODIFY State VARCHAR(255),
MODIFY Country VARCHAR(255);




ALTER TABLE Orders
MODIFY Order_ID VARCHAR(255) PRIMARY KEY,
MODIFY Order_Date DATE,
MODIFY Ship_Mode VARCHAR(255),
MODIFY Period INT,
MODIFY Customer_ID VARCHAR(255),
MODIFY Sub_Category VARCHAR(255),
MODIFY Ship_date VARCHAR(255),
ADD FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID);


ALTER TABLE Products
MODIFY Category VARCHAR(255),
MODIFY Sub_Category VARCHAR(255),
ADD PRIMARY KEY (Category, Sub_Category);

ALTER TABLE Sales
MODIFY Row_ID INT PRIMARY KEY,
MODIFY Order_ID VARCHAR(255),
MODIFY Customer_ID VARCHAR(255),
MODIFY Costs DECIMAL(20, 3),
MODIFY Discount DECIMAL(5, 3),
MODIFY Profit DECIMAL(20, 3),
MODIFY `Profitable?` ENUM('Yes', 'No'),
MODIFY Quantity INT,
MODIFY SCP DECIMAL(20, 3),
MODIFY Sales DECIMAL(20, 3),
MODIFY Sub_Category VARCHAR(255),
ADD FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
ADD FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID);


-- lets double check all tables again.
DESCRIBE customers 
DESCRIBE orders
DESCRIBE products
DESCRIBE sales


/*Let's write some queries which are usefull from these dataset:
Some Basic Information:
1-How many rows are there in the table?
2-What are the distinct categories of products (Category) in the dataset?
3-How many unique customers (Customer ID) are there?

Orders and Sales:
4-What is the total sales (Sales) amount in the dataset?
5-How many orders (Order ID) were placed in a specific period?
6-What is the average order quantity (Quantity)?

Geographical Insights:
7-How many unique cities (City) are included in the dataset?
8-What is the total profit (Profit) by country (Country)?
9-which region (Region) has the highest sales?

Customer Analysis:
10-Who are the top 10 customers (Customer Name) by total sales?
11-What is the average profit margin (Profit / Sales) per customer?
12-How many customers placed orders in each category of products?

Product Analysis:
13-What are the top 5 most profitable products (Product Name)?
14-How many products (Product ID) fall under each category and sub-category?
15-What is the average discount (Discount) offered on products?

Time Analysis:
16-What is the distribution of orders  over different periods?
17-What is the average shipping duration (Ship Date - Order Date)?
18-How many orders were profitable (Profitable or not?) in each month?

Segmentation and Analysis:
19-How does the profitability vary by segment (Segment)?
20-Which segment has the highest average discount?

Shipping and Logistics:
21-What are the most common shipping modes used?
22-How does shipping mode affect profit margins?

Cost Analysis:
23-What is the total cost (Costs) incurred per product category?
24-How does discount impact profitability across different product types?

Customer and Order Analysis:
25-How many orders (Order ID) were placed by each customer (Customer ID) in each category (Category)? 

Profitability Analysis:
26-Calculate the total profit (Profit) and loss for each product (Product Name) across different regions (Region).

Order and Shipping Analysis:
27-How many orders (Order ID) were shipped late (Ship Date > Order Date + 3 days) for each product category (Category)?

Customer Segmentation:
28-Classify customers (Customer ID) into segments (Segment) based on their total sales (SUM(Sales)) and average
29-Customer Lifetime Value (CLV) Analysis
*/
-- 1.How many rows are there in the table?
SELECT 
    COUNT(*) AS row_count
FROM
    cleaned_sale_dataset;

-- 2.What are the distinct categories of products (Category) in the dataset?
SELECT DISTINCT
    Category
FROM
    products;

-- 3.How many unique customers (Customer ID) are there?
SELECT 
    COUNT(DISTINCT Customer_ID) AS unique_customers
FROM
    customers;
Orders and Sales:

-- 4.What is the total sales (Sales) amount in the dataset?
SELECT SUM(Sales) AS total_sales
FROM sales;

-- 5.How many orders were placed in a specific period?
SELECT COUNT(DISTINCT Order_ID) AS order_count
FROM orders
WHERE DATE_FORMAT(Order_Date, '%Y-%m') = '2023-01';

-- 6. What is the average order quantity?
SELECT AVG(Quantity) AS average_quantity
FROM sales;

-- 7.How many unique cities (City) are included in the dataset?
SELECT COUNT(DISTINCT City) AS unique_cities
FROM customers;

-- 8.What is the total profit (Profit) by country (Country)?
SELECT 
    Country, SUM(Profit) AS total_profit
FROM
    customers c
        JOIN
    sales s ON c.Customer_ID = s.Customer_ID
GROUP BY Country;

-- 9.Which region (Region) has the highest sales?
SELECT 
    Region, SUM(Sales) AS total_sales
FROM
    customers c
        JOIN
    sales s ON c.Customer_ID = s.Customer_ID
GROUP BY Region
ORDER BY total_sales DESC
LIMIT 1;

-- 10.Who are the top 10 customers (Customer Name) by total sales?
SELECT 
    c.Customer_Name, SUM(s.Sales) AS total_sales
FROM
    customers c
        JOIN
    sales s ON c.Customer_ID = s.Customer_ID
GROUP BY c.Customer_Name
ORDER BY total_sales DESC
LIMIT 10;

-- 11.What is the average profit margin (Profit / Sales) per customer?
SELECT 
    Customer_ID, AVG(Profit / Sales) AS average_profit_margin
FROM
    sales
GROUP BY Customer_ID;

-- 12.How many customers placed orders in each category of products?
SELECT 
    p.Category, COUNT(DISTINCT s.Customer_ID) AS customer_count
FROM
    sales s
        JOIN
    products p USING (sub_category)
GROUP BY p.Category;

-- 13.What are the top 5 most profitable products?
SELECT 
    p.Product_Name, SUM(s.Profit) AS total_profit
FROM
    sales s
        JOIN
    products p ON s.Product_ID = p.Product_ID
GROUP BY p.Product_Name
ORDER BY total_profit DESC
LIMIT 5;

-- 14.How many products fall under each category and sub-category?
SELECT 
    Category, Sub_Category, COUNT(sub_category) AS product_count
FROM
    products p
        JOIN
    sales s USING (sub_category)
GROUP BY 1 , 2;

-- 15.What is the average discount offered on products?
-- sub_category:
SELECT 
    sub_category, ROUND(AVG(discount), 3)
FROM
    sales
GROUP BY 1
ORDER BY 2 DESC
-- category:
SELECT 
    p.category, ROUND(AVG(s.discount), 3)
FROM
    sales s
        JOIN
    products p USING (sub_category)
GROUP BY 1
ORDER BY 2 DESC


-- 16.What is the distribution of orders over different periods?
SELECT
    DATE_FORMAT(o.Order_Date, '%Y-%m') AS Period,
    COUNT(s.order_id) AS Order_Count
FROM
    sales s
JOIN
    orders o USING (Order_ID)
GROUP BY
    DATE_FORMAT(o.Order_Date, '%Y-%m')
ORDER BY
    Period;

-- 17.What is the average shipping duration?
SELECT AVG(DATEDIFF(Ship_date, Order_Date)) AS AvgShippingDuration -- DATEDIFF(date1, date2) 
FROM sales;

-- 18-How many orders were profitable in each month?
-- we have to consider orders where Profit > 0 as profitable
SELECT 
    YEAR(Order_Date) AS Order_Year,
    MONTH(Order_Date) AS Order_Month,
    COUNT(*) AS Profitable_Orders_Count
FROM 
    cleaned_sale_dataset
WHERE 
    Profit > 0  -- Consider orders where Profit > 0 as profitable
GROUP BY 
    Order_Year, Order_Month
ORDER BY 
    Order_Year desc, Order_Month; -- In order to order year and month acceptable, we have to do our order by, with both of them

-- 19.How does the profitability vary by segment (Segment)?
SELECT 
    c.Segment, 
    round(AVG(cd.Profit), 3) AS AverageProfit, 
    round(AVG(cd.Profit / cd.Sales), 3) AS AverageProfitMargin
FROM 
    cleaned_sale_dataset cd
JOIN 
    customers c ON cd.Customer_ID = c.Customer_ID
WHERE 
    c.Segment IS NOT NULL
GROUP BY 
    c.Segment
ORDER BY 
    AverageProfitMargin DESC;

-- 20. segment with highest average discount
-- I have forgot to add segment coloumn to customers table, so I want to do it here
-- first I have to make this coloumn in my customers table.
ALTER TABLE customers  
ADD COLUMN Segment VARCHAR(255);
-- now I have to add whatever we have in this coloumn in cleaned_dataset which is our source dataset, into our customers table
UPDATE customers c
JOIN (
    SELECT DISTINCT Customer_ID, Segment
    FROM cleaned_sale_dataset
) cd ON c.Customer_ID = cd.Customer_ID
SET c.Segment = cd.Segment;
-- Now lets answer the question
-- First answer uses CTE which is faster, but you can not have for example, secound highest too it only shows the hightest
WITH AvgDiscounts AS (
    SELECT 
        c.Segment, 
        round(AVG(s.Discount),2) AS AverageDiscount
    FROM 
        sales s
    JOIN 
        customers c USING (Customer_ID)
        where segment is not null
    GROUP BY 
        c.Segment
)
SELECT 
    Segment, 
    AverageDiscount
FROM 
    AvgDiscounts
WHERE 
    AverageDiscount = (SELECT MAX(AverageDiscount) FROM AvgDiscounts)
-- second answer has a benefit which let us to choose the 2th, 3th, ... segmeng which is highest or even lowerest (by changing order by to asc)
-- howver, if we want only the second highest or second lowerest, this code will not help us
SELECT 
    c.Segment, 
    AVG(s.Discount) AS AverageDiscount
FROM 
    sales s
JOIN 
    customers c USING (Customer_ID)
where segment is not null
GROUP BY 
    c.Segment
ORDER BY 
    AverageDiscount DESC
LIMIT 1;
-- Now by using dense_rank function we can choose whatever we wants, for example 4th highest, or 10th lowerest.
WITH AvgDiscounts AS (
    SELECT 
        c.Segment, 
        AVG(s.Discount) AS AverageDiscount,
        DENSE_RANK() OVER (ORDER BY AVG(s.Discount) DESC) AS Rk
    FROM 
        sales s
    JOIN 
        customers c USING (Customer_ID)
	where segment is not null
    GROUP BY 
        c.Segment
)
SELECT 
    Segment, 
    round(AverageDiscount,3) as avg_discount
FROM 
    AvgDiscounts
WHERE 
    Rk = 1;

-- 21. how shipping mode affects profit margins
SELECT 
    o.Ship_Mode,
    SUM(s.Sales) AS TotalSales,
    SUM(s.Profit) AS TotalProfit,
    round((SUM(s.Profit) / SUM(s.Sales)) * 100,3) AS ProfitMarginPercentage
FROM 
    sales s
join 
	orders o using(order_id)
GROUP BY 
    o.Ship_Mode
ORDER BY 
    ProfitMarginPercentage DESC;


-- 22.What is the total cost (Costs) incurred per product category?
select p.category, sum(s.costs)
from sales s
join products p using (sub_category)
group by 1
order by 2 desc

-- 23 how does discount impacts profit per sub_category?
SELECT 
    Sub_Category AS ProductType,
    AVG(Discount) AS AverageDiscount,
    AVG(Profit) AS AverageProfit,
    SUM(Profit) AS TotalProfit,
    CASE
        WHEN AVG(Discount) > 0 THEN AVG(Profit / Sales) / AVG(Discount)
        ELSE 0
    END AS DiscountImpact
FROM 
    sales
GROUP BY 
    Sub_Category
ORDER BY 
    5 DESC;


-- 24 How many orders had a city provided?
select c.city, count(s.order_id)
from customers c 
join sales s using(customer_id)
group by 1
order by 2 desc

-- 25 How many orders were placed by each customer in each category? 
select o.customer_id, p.category, count(s.order_id)
from sales s
join orders o on o.Order_ID = s.Order_ID -- or using(order_id)
join products p on p.Sub_Category = o.Sub_Category -- or p.sub_category = s.sub_category
group by 1,2
order by 3 desc

-- 26 Calculate the total profit  and loss for each sub_category across different States
select
s.sub_category,  c.state, sum(s.profit) 
from sales s
join customers c using(customer_id)
group by 1,2
order by 3 desc

-- 27 Latency in shiping (more than a year)
SELECT COUNT(order_id) AS OrderCount
FROM orders
WHERE ship_date > DATE_ADD(order_date, INTERVAL 365 DAY);

-- 28 Classify Customers into Segments based on total sales and average
SELECT 
    Customer_ID,
    SUM(Sales) AS TotalSales,
    AVG(Sales) AS AvgSales,
    CASE
        WHEN SUM(Sales) >= 10000 THEN 'High Value'
        WHEN SUM(Sales) >= 5000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS TotalSalesSegment,
    CASE
        WHEN AVG(Sales) >= 1000 THEN 'High Average'
        WHEN AVG(Sales) >= 500 THEN 'Medium Average'
        ELSE 'Low Average'
    END AS AvgSalesSegment,
    CASE
        WHEN SUM(Sales) >= 10000 AND AVG(Sales) >= 1000 THEN 'Premium'
        WHEN SUM(Sales) >= 5000 AND AVG(Sales) >= 500 THEN 'Valuable'
        ELSE 'Standard'
    END AS CustomerSegment
FROM 
    sales
GROUP BY 
    Customer_ID
ORDER BY 
    TotalSales DESC;

-- 29 Identify Active Customers (customers who made a purchase in the last 12 months)
with clv as (
select o.ship_date, o.order_id, s.sales, s.customer_id
from sales s
join orders o using (order_id)
			)
SELECT 
    Customer_ID,
    SUM(Sales) AS TotalRevenue,
    round(AVG(Sales),3) AS AvgOrderValue,
    COUNT(Order_ID) AS TotalOrders,
    DATEDIFF(MAX(Ship_Date), MIN(Ship_Date)) AS LifetimeMonths,
    round((SUM(Sales) / DATEDIFF(MAX(Ship_Date), MIN(Ship_Date))), 3) AS RevenuePerMonth,
    round((AVG(Sales) * COUNT(Order_ID)),3) AS CustomerValue,
    round(((SUM(Sales) / DATEDIFF(MAX(Ship_Date), MIN(Ship_Date))) * 12) * 3,3) AS CLV  -- Assuming customer lifespan is 3 years
FROM 
    clv
WHERE 
    Ship_Date >= DATE_SUB(NOW(), INTERVAL 12 MONTH)
GROUP BY 
    Customer_ID
ORDER BY 
    CLV DESC;