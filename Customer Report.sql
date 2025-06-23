-- Customer metrics and Behaviours
CREATE VIEW report_customers AS
-- cte - joins the customer and fact sales & retreives the required columns 
WITH cte AS (SELECT f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
TIMESTAMPDIFF(YEAR, c.birthdate, CURDATE()) AS age
FROM fact_sales f
LEFT JOIN dim_customers c
ON f.customer_key = c.customer_key
WHERE order_date IS NOT NULL),

-- summarizing key metrics at customer level
customer_aggregation AS(
SELECT customer_key,
customer_number,
customer_name,
age,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
COUNT(product_key) AS total_products,
MAX(order_date) AS last_order_date,
TIMESTAMPDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM cte
GROUP BY customer_key, customer_number, customer_name, age)

SELECT customer_key,
customer_number,
customer_name,
age,
-- Seggregating customers based on their total spent and their period with the company
CASE
	WHEN lifespan >= 12 AND total_sales > 5000 THEN "VIP"
    WHEN lifespan >= 12 AND total_sales < 5000 THEN "Regular"
    ELSE "New"
    END AS customer_type,
-- Creating customer demographics based on their age
CASE
	WHEN age < 20 THEN "Below 20"
    WHEN age BETWEEN 20 AND 29 THEN "20-29"
    WHEN age BETWEEN 30 AND 39 THEN "30-39"
    WHEN age BETWEEN 40 AND 49 THEN "40-49"
    ELSE "Above 50"
    END AS age_group,
total_sales,
total_quantity,
total_products,
last_order_date,
TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) AS recency,
lifespan,
-- Computing Average Order Value (AOV)
CASE
	WHEN total_sales = 0 THEN 0
    ELSE ROUND(total_sales / total_products, 0)
    END AS AOV,
-- Computing Average Monthly Spend (AMS)
CASE
	WHEN lifespan = 0 THEN total_sales
    ELSE ROUND(total_sales / lifespan, 0)
    END AS AMS
FROM customer_aggregation