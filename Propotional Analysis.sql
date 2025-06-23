-- Analyzing each category sales compared to overall sales

WITH cte AS(
SELECT p.category AS Category,
SUM(sales_amount) AS total_sales
FROM fact_sales f
LEFT JOIN dim_products p
ON f.product_key = p.product_key
GROUP BY p.category)

SELECT Category,
total_sales,
SUM(total_sales) OVER() AS overall_sales,
CONCAT(ROUND(total_sales / SUM(total_sales) OVER(), 2) * 100, "%") AS percentage_share
FROM cte
ORDER BY 4 DESC;