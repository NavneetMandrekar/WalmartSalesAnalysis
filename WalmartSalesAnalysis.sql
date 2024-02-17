CREATE DATABASE IF NOT EXISTS salesDataWalmart;

CREATE TABLE IF NOT EXISTS sales(
  invoice_id varchar(30) not null primary key,
  branch varchar(5) not null,
  city varchar(30) not null,
  customer_type varchar(30) not null,
  gender varchar(10) not null,
  product_line varchar(100) not null,
  unit_price decimal(10,2) not null,
  quantity int not null,
  VAT float(6,4) not null,
  total decimal(12, 4) not null,
  date DATETIME not null,
  time TIME not null,
  payment_method varchar(15) not null,
  cogs decimal(10,2) not null,
  gross_margin_pct float(11,9),
  gross_income decimal(12,4) not null,
  reting float(2,1)
);


-- --------------------------------------------------------------------------------------
-- ----------------------------------- Feature Engineering ------------------------------


-- Change name of the column
ALTER TABLE sales
RENAME COLUMN reting TO rating;



-- time_of_day

SELECT time,
(CASE
     WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
     WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
     ELSE "Evening"
 END
) AS time_of_day
 FROM sales;
 
 ALTER table sales ADD COLUMN time_of_day VARCHAR(20);
 
 UPDATE sales 
 SET time_of_day = (
 CASE
     WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
     WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
     ELSE "Evening"
 END
 );
 
-- day_name

SELECT 
   date,
   dayname(date) AS day_name
from sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
 SET day_name = dayname(date);
 
 -- month_name
 
 SELECT 
   date,
   monthname(date) AS month_name
from sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
 SET month_name = monthname(date);
-- --------------------------------------------------------------------------------------


-- --------------------------------------------------------------------------------------
-- ------------------------------Generic-------------------------------------------------

-- How many unique cities does the data have?

SELECT DISTINCT(city) from sales;

-- In which city is each branch?
SELECT DISTINCT city,branch from sales;

-- ---------------------------------------------------------------------------------------
-- ---------------------------- Product --------------------------------------------------
-- ---------------------------------------------------------------------------------------

-- How many unique product lines does the data have?
SELECT
 COUNT(DISTINCT product_line)
from sales;

-- What is the most common payment method?
SELECT
   payment_method, 
   COUNT(payment_method) AS cnt
from sales
GROUP BY payment_method
ORDER BY cnt DESC;


-- What is the most selling product line
 SELECT 
  product_line,
  SUM(quantity) AS qty
 FROM sales
 GROUP BY product_line
 ORDER BY qty DESC;
 
 
 -- What is the total revenue by month
 SELECT
   month_name as month,
   SUM(total) as total_revenue
 FROM sales
 GROUP BY month_name
 ORDER BY total_revenue DESC;
 
 
 -- What month had the largest COGS?
 SELECT
   month_name as month,
   SUM(cogs) as cogs
 FROM sales
 GROUP BY month_name
 ORDER BY cogs DESC;
 
 
 -- What product line had the largest revenue?
 SELECT 
    product_line,
    SUM(total) AS total_revenue
 FROM sales
 GROUP BY product_line
 ORDER BY total_revenue DESC;
 
 
 -- What is the city with the largest revenue?
 SELECT 
    city,
    SUM(total) AS total_revenue
 FROM sales
 GROUP BY city
 ORDER BY total_revenue DESC;
 
 
 -- What product line had the largest VAT?
  SELECT 
    product_line,
    AVG(VAT) AS tax
 FROM sales
 GROUP BY product_line
 ORDER BY tax DESC;
 
 
-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales
SELECT 
  product_line,
  CASE
    WHEN quantity > AVG(quantity) THEN "Good"
    ELSE "Bad"
  END AS remark
FROM sales
GROUP BY product_line;



-- Which branch sold more products than average product sold?
SELECT 
   branch,
   SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING qty > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender?
SELECT
 gender,
 product_line,
 COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender,product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line?
SELECT
 product_line,
 ROUND(AVG(rating), 2) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;


-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- -------------------------- Sales -----------------------------------
-- --------------------------------------------------------------------


-- Number of sales made in each time of the day per weekday
SELECT
  time_of_day,
  SUM(quantity) as qty
FROM sales
WHERE day_name="Sunday"
GROUP BY time_of_day
ORDER BY qty DESC;

-- Which of the customer types brings the most revenue?
SELECT
  customer_type,
  ROUND(SUM(total),2) as total_rev
FROM sales
GROUP BY customer_type
ORDER BY total_rev DESC;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT
  city,
  AVG(VAT) as VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC;

-- Which customer type pays the most in VAT?
SELECT
  customer_type,
  AVG(VAT) as VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT DESC;



-- --------------------------------------------------------------------
-- -------------------------- Customer -----------------------------------
-- --------------------------------------------------------------------

-- How many unique customer types does the data have?
SELECT
   DISTINCT(customer_type)
FROM sales;

-- How many unique payment methods does the data have?
SELECT
   DISTINCT(payment_method)
FROM sales;

-- What is the most common customer type?
SELECT
   customer_type,
   COUNT(*) AS cst_count
FROM sales
GROUP BY customer_type
ORDER BY cst_count DESC;

-- What is the gender of most of the customers?
SELECT
   gender,
   COUNT(*) AS gender_count
FROM sales
GROUP BY gender
ORDER BY gender_count DESC;

-- What is the gender distribution per branch?
SELECT
   gender,
   COUNT(*) AS gender_count
FROM sales
WHERE branch = "A"
GROUP BY gender
ORDER BY gender_count DESC;

-- Which time of the day do customers give most ratings?
SELECT 
   time_of_day,
   AVG(rating) as avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT 
   time_of_day,
   AVG(rating) as avg_rating
FROM sales
WHERE branch = "C"
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which day fo the week has the best avg ratings?
SELECT 
   day_name,
   AVG(rating) as avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT 
   day_name,
   AVG(rating) as avg_rating
FROM sales
WHERE branch = "A"
GROUP BY day_name
ORDER BY avg_rating DESC;