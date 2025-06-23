-- Segmenting Data based on Cost and customer type

-- Categorizing data based on cost ranging from 100 to 1000
WITH cost_seg AS (
SELECT product_key,
product_name,
cost,
CASE
	WHEN cost < 100 THEN "Below 100"
    WHEN cost BETWEEN 100 AND 500 THEN "100 - 500"
    WHEN cost BETWEEN 500 AND 1000 THEN "500 - 1000"
    ELSE "Above 1000"
    END AS cost_range
FROM dim_products
WHERE cost > 0)

SELECT cost_range,
COUNT(product_key) AS total_products
FROM cost_seg
GROUP BY 1
ORDER BY 2 DESC;

-- Categorizing data based on customer type
-- VIP = lifespan more than 12 months and spent more than 5000$
-- Regular = lifespan more than 12 months but spent less than 5000$
-- New = lifespan less than 12 months

WITH cust_seg AS(
SELECT c.customer_key,
MIN(f.order_date) AS first_order,
MAX(f.order_date) AS last_order,
TIMESTAMPDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
SUM(f.sales_amount) AS total_spent
FROM fact_sales f
LEFT JOIN dim_customers c
ON f.customer_key = c.customer_key
GROUP BY 1),

cust_group AS(
SELECT customer_key,
lifespan,
total_spent,
CASE
	WHEN lifespan >= 12 AND total_spent > 5000 THEN "VIP"
    WHEN lifespan >= 12 AND total_spent < 5000 THEN "Regular"
    ELSE "New"
    END AS customer_type
FROM cust_seg)

SELECT 
  customer_type,
  COUNT(customer_key) AS total_customers
FROM cust_group
GROUP BY customer_type
ORDER BY 2 DESC;