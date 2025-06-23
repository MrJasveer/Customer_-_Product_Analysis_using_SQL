
-- Finding patterns in sales
-- either by year or month or even dates

SELECT YEAR(order_date) AS the_year,
MONTH(order_date) AS the_month,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity
FROM fact_sales
WHERE YEAR(order_date) IS NOT NULL
AND MONTH(order_date) IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)

-- The table below will give you insghts on which month the business is doing great and the month business is slow
-- these are C level insights that would require details if asked for specefics