-- Analyzing performance of each products
-- BY Yearly Average Sales
-- By Previous Year Sales
WITH yearly_performance AS(
SELECT YEAR(f.order_date) AS order_year,
p.product_name,
SUM(sales_amount) AS total_sales
FROM fact_sales f
LEFT JOIN dim_products p
ON f.product_key = p.product_key
WHERE YEAR(f.order_date) IS NOT NULL
GROUP BY 1, 2
ORDER BY 1)

SELECT order_year, product_name, total_sales,
ROUND(AVG(total_sales) OVER (PARTITION BY product_name), 0) AS avg_sales,
(total_sales - ROUND(AVG(total_sales) OVER (PARTITION BY product_name), 0)) AS avg_diff,
CASE
	WHEN (total_sales - ROUND(AVG(total_sales) OVER (PARTITION BY product_name), 0)) > 0 THEN "Above Avg"
	WHEN (total_sales - ROUND(AVG(total_sales) OVER (PARTITION BY product_name), 0)) < 0 THEN "Below Avg"
    ELSE "Neutral"
    END AS "Target_Avg",
LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_year_sale,
(total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year)) AS py_diff,
CASE
	WHEN (total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year)) > 0 THEN "Increase"
	WHEN (total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY order_year)) < 0 THEN "Decrease"
    ELSE "No Change"
    END AS "Target_py_change"
FROM yearly_performance
ORDER BY product_name, order_year;