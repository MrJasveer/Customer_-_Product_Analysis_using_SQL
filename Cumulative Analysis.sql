-- Aggregate data progressively over time
-- helps to understand if business growing or declining
-- eg - Running total Sales, Moving avg Sales

-- Calculating total sales per month and running total sales per year

WITH month_sales AS (
SELECT DATE_FORMAT(order_date, '%Y-%m-01') AS the_month, SUM(sales_amount) AS total_sales
FROM fact_sales
WHERE DATE_FORMAT(order_date, '%Y-%m-01') IS NOT NULL
GROUP BY the_month)

SELECT the_month, total_sales, SUM(total_sales) OVER (PARTITION BY the_month ORDER BY the_month) AS Cumulative_Sales
FROM month_sales;

-- Calculating avg price per month and running total sales per year

WITH month_sales AS (
SELECT DATE_FORMAT(order_date, '%Y-%m-01') AS the_month, 
YEAR(order_date) AS the_year, AVG(price) AS avg_price
FROM fact_sales
WHERE DATE_FORMAT(order_date, '%Y-%m-01') IS NOT NULL
GROUP BY the_month, the_year)

SELECT the_month, avg_price, SUM(avg_price) OVER (PARTITION BY the_year ORDER BY the_month) AS moving_avg_price
FROM month_sales;