-- Walmart Project Queries

SELECT * FROM walmart;

-- DROP TABLE walmart;

-- 
SELECT COUNT(*) FROM walmart;


SELECT 
	 payment_method,
	 COUNT(*)
FROM walmart
GROUP BY payment_method

SELECT 
	COUNT(DISTINCT branch) 
FROM walmart;

SELECT MIN(quantity) FROM walmart;

-- Business Problems
--Q.1 Find different payment method and number of transactions, number of qty sold


SELECT 
	 payment_method,
	 COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method


-- Project Question #2
-- Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING

SELECT * 
FROM
(	SELECT 
		branch,
		category,
		AVG(rating) as avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
)
WHERE rank = 1


-- Q.3 Identify the busiest day for each branch based on the number of transactions

SELECT * 
FROM
	(SELECT 
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') as day_name,
		COUNT(*) as no_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
	FROM walmart
	GROUP BY 1, 2
	)
WHERE rank = 1

-- Q. 4 
-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.



SELECT 
	 payment_method,
	 -- COUNT(*) as no_payments,
	 SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method


-- Q.5
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

SELECT 
	city,
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating
FROM walmart
GROUP BY 1, 2


-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

SELECT 
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin) as profit
FROM walmart
GROUP BY 1


-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.

WITH cte 
AS
(SELECT 
	branch,
	payment_method,
	COUNT(*) as total_trans,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1, 2
)
SELECT *
FROM cte
WHERE rank = 1


-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

SELECT
	branch,
CASE 
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC

-- 
-- Q.9 
-- Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart


-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 -- psql
	-- WHERE YEAR(TO_DATE(date, 'DD/MM/YY')) = 2022 -- mysql
	GROUP BY 1
),


revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5

----

-- Q.10
-- Branch-Wise Total Sales

SELECT 
    branch, 
    SUM(total) AS total_sales
FROM 
    walmart
GROUP BY 
    branch
ORDER BY 
    total_sales DESC;

-- Q.11 
--Sales Impact by Rating

SELECT 
    CASE 
        WHEN rating >= 9 THEN 'Excellent'
        WHEN rating BETWEEN 7 AND 8.9 THEN 'Good'
        WHEN rating BETWEEN 5 AND 6.9 THEN 'Average'
        ELSE 'Poor'
    END AS rating_category, 
    COUNT(invoice_id) AS transaction_count, 
    SUM(total) AS total_sales
FROM 
    walmart
GROUP BY 
    rating_category
ORDER BY 
    total_sales DESC;

-- Q.12
-- Total Sales by City and Category

SELECT 
    city, 
    category, 
    SUM(total) AS total_sales
FROM 
    walmart
GROUP BY 
    city, 
    category
ORDER BY 
    city, 
    total_sales DESC;

-- Q.13
-- Identify Branches with the Highest Profit Margin by Category, and Rank Them

WITH branch_category_profit AS (
    SELECT 
        branch, 
        category, 
        AVG(profit_margin) AS avg_profit_margin
    FROM 
        walmart
    GROUP BY 
        branch, 
        category
)
SELECT 
    branch, 
    category, 
    avg_profit_margin, 
    RANK() OVER (PARTITION BY category ORDER BY avg_profit_margin DESC) AS rank
FROM 
    branch_category_profit
ORDER BY 
    category, 
    rank;

-- Q.14
-- Find the Correlation Between Rating and Total Sales Using a Subquery
SELECT 
    rating,
    AVG(total) AS avg_sales,
    COUNT(invoice_id) AS total_transactions,
    (SELECT CORR(rating, total) FROM walmart) AS correlation_rating_sales
FROM 
    walmart
GROUP BY 
    rating
ORDER BY 
    avg_sales DESC;

-- Q.15 
--  Calculate the Most Profitable Category by Branch Over Time
WITH monthly_sales AS (
    SELECT 
        branch, 
        category, 
        EXTRACT(YEAR FROM DATE date) AS sale_year,
        EXTRACT(MONTH FROM DATE date) AS sale_month,
        SUM(total) AS total_sales
    FROM 
        walmart
    GROUP BY 
        branch, 
        category, 
        sale_year, 
        sale_month
)
SELECT 
    branch, 
    sale_year, 
    sale_month, 
    category, 
    total_sales,
    RANK() OVER (PARTITION BY branch, sale_year, sale_month ORDER BY total_sales DESC) AS rank
FROM 
    monthly_sales
WHERE 
    rank = 1
ORDER BY 
    branch, 
    sale_year, 
    sale_month;


-- Q.16
-- Join with a Subquery to Find the Branch 
-- with Highest Sales in a Specific Category

SELECT 
    w.branch, 
    w.category, 
    SUM(w.total) AS total_sales
FROM 
    walmart w
WHERE 
    w.category = 'Health and beauty'
GROUP BY 
    w.branch, w.category
HAVING 
    SUM(w.total) = (
        SELECT MAX(total_sales)
        FROM (
            SELECT SUM(w.total) AS total_sales
            FROM walmart w
            WHERE w.category = 'Health and beauty'
            GROUP BY w.branch
        ) AS subquery
    )
ORDER BY 
    total_sales DESC;
