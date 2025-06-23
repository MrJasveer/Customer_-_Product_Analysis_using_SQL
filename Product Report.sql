-- Product Metrics & KPI's
CREATE VIEW report_products AS
-- cte - joins the products and fact sales & retreives the required columns 
WITH cte AS(SELECT f.product_key,
f.quantity,
f.sales_amount,
f.order_date,
f.order_number,
f.customer_key,
p.product_name,
p.category,
p.subcategory,
p.cost
FROM fact_sales f
JOIN dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL),
-- summarizing key metrics at product level
product_aggregation AS(
SELECT product_key,
product_name,
order_number,
category,
subcategory,
COUNT(order_number) AS total_orders,
COUNT(customer_key) AS total_customers,
SUM(quantity) AS total_quantity,
SUM(sales_amount) AS total_sales,
SUM(cost) AS total_cost,
ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price,
MAX(order_date) AS last_order_date,
TIMESTAMPDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM cte
GROUP BY product_key, product_name, category, subcategory, order_number)

SELECT product_key,
product_name,
category,
subcategory,
-- Seggregating Product based on their sales
CASE
	WHEN total_sales > 50000 THEN 'High Performer'
    WHEN total_sales >= 10000 THEN 'Mid_range'
    ELSE 'Low Performer'
    END AS product_segment,
total_customers,
total_quantity,
total_sales,
total_cost,
last_order_date,
TIMESTAMPDIFF(MONTH, last_order_date, CURDATE()) AS recency,
-- Computing Average Order Value (AOV)
CASE
	WHEN total_orders = 0 THEN 0
    ELSE total_sales / total_orders
    END AS AOV,
-- Computing Average Monthly Revenue (AMR)
CASE
	WHEN lifespan = 0 THEN total_sales
    ELSE total_sales / lifespan
    END AS AMR
FROM product_aggregation