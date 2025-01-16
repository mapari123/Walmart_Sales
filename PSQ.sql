SELECT * FROM public.walmart
LIMIT 100

select count(*) from walmart;

select 
     payment_method,
	 COUNT(*)
FROM WALMART
GROUP BY payment_method

SELECT COUNT(DISTINCT "Branch") 
FROM "walmart";

select MIN(quantity)
FROM walmart

-- Business Problems
--Find different payment method and number of transactions, number of qty sold

select 
    payment_method,
	COUNT(*) as no_pyment,
	SUM(quantity) as no_qty_sold
from walmart
GROUP BY payment_method


-- Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING

SELECT "Branch", category
FROM (
    SELECT 
        "Branch",
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY "Branch" ORDER BY AVG(rating) DESC) AS rank
    FROM walmart
    GROUP BY "Branch", category
) subquery
WHERE rank = 1;

--- Identify the busiest day for each branch based on the number of transactions

select *
from 
  (select
          "Branch",
		  To_CHAR(TO_DATE(date, 'DD/MM/YY'),'Day')as day_name,
		  COUNT(*) as no_transactions,
		  RANK() OVER(PARTITION BY "Branch" ORDER BY COUNT(*)DESC)as rank
from walmart
GROUP BY 1,2
)
WHERE rank = 1


-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

SELECT
      payment_method,
	  COUNT(*) as no_payments,
	  sum(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method

-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

select 
    "City",
	"category",
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating
FROM walmart
GROUP BY 1,2

-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

select
      category,
	  SUM(total) as total_revenue,
	  SUM(total*profit_margin)as profit
FROM walmart
GROUP BY 1
ORDER BY profit DESC;



-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.

WITH cte 
AS
(SELECT 
	"Branch",
	"payment_method",
	COUNT(*) as total_trans,
	RANK() OVER(PARTITION BY "Branch" ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1, 2
)
SELECT *
FROM cte
WHERE rank = 1
      


-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

SELECT
     "Branch",
case
             WHEN EXTRACT(HOUR FROM(time::time))< 12 THEN 'Morning'
			 WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
			 ELSE 'Evening'
       END day_time,
	   COUNT(*)
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC


-- Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100

-- 2022 sales
WITH revenue_2022 AS
(
    SELECT 
        "Branch",
        SUM(total) as revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
    GROUP BY "Branch"
),

revenue_2023 AS
(
    SELECT 
        "Branch",
        SUM(total) as revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY "Branch"
)

SELECT 
    ls."Branch",
    ls.revenue AS last_year_revenue,
    cs.revenue AS cr_year_revenue,
    ROUND(
        (ls.revenue - cs.revenue)::numeric /
        ls.revenue::numeric * 100, 
        2
    ) AS rev_dec_ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs
    ON ls."Branch" = cs."Branch"
WHERE ls.revenue > cs.revenue
ORDER BY rev_dec_ratio DESC
LIMIT 5;
