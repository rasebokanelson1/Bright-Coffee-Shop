-- Databricks notebook source
-- Selecting/ specifying Database and Schema to be used
USE CATALOG brightcoffee;
USE SCHEMA shop;

-- Previewing Dataset
SELECT *
FROM bright_coffee_shop_sales;

-- Describing the data types and checking for nulls in each column
DESCRIBE TABLE bright_coffee_shop_sales;

-- Finding the unique store locations
SELECT DISTINCT store_location
FROM bright_coffee_shop_sales;

-- Counting the total number of rows in the entire table
SELECT COUNT(*) AS total_rows
FROM bright_coffee_shop_sales;

-- Counting the total number of rows in the transaction_id column
SELECT COUNT(transaction_id) AS trans_id_count
FROM bright_coffee_shop_sales;

-- Counting the total number of unique rows in the transaction_id column (Checks for duplicates)
SELECT COUNT(DISTINCT transaction_id) AS dist_trans_id_count
FROM bright_coffee_shop_sales;

-- Finding columns with nulls
SELECT *
FROM bright_coffee_shop_sales
WHERE transaction_id IS NULL
        OR transaction_date IS NULL
        OR transaction_time IS NULL
        OR transaction_qty IS NULL
        OR store_id IS NULL
        OR store_location IS NULL
        OR product_id IS NULL
        OR unit_price IS NULL
        OR product_category IS NULL
        OR product_type IS NULL
        OR product_detail IS NULL;

-- Replacing NULLS with zero
SELECT COALESCE(transaction_qty, 0) AS transactions_no_nulls
FROM bright_coffee_shop_sales;

-- Data range of the dataset
SELECT MIN(transaction_date) AS earliest_date,
        MAX(transaction_date) AS latest_date
FROM bright_coffee_shop_sales;

-- Remove timestanp
SELECT transaction_time,
        DATE_FORMAT(transaction_time, 'hh:mm:ss') AS clean_time
FROM bright_coffee_shop_sales;

-- Product hierachy/ levels
SELECT DISTINCT product_category
                product_type,
                product_detail
FROM bright_coffee_shop_sales;

SELECT DISTINCT product_category
FROM bright_coffee_shop_sales;

SELECT DISTINCT product_type
FROM bright_coffee_shop_sales;

SELECT DISTINCT product_detail
FROM bright_coffee_shop_sales;

-- Transactions per day
SELECT transaction_date,
        COUNT(DISTINCT transaction_id) AS total_transactions
FROM bright_coffee_shop_sales
GROUP BY transaction_date;

-- Transactions per month
SELECT MONTHNAME(transaction_date) AS month_name,
        COUNT(DISTINCT transaction_id) AS total_transactions
FROM bright_coffee_shop_sales
GROUP BY month_name;

-- Revenue per month
SELECT MONTHNAME(transaction_date) AS month_name,
        ROUND(SUM(CAST(REPLACE(unit_price, ',','.') AS DOUBLE) * transaction_qty), 2) AS monthly_revenue
FROM bright_coffee_shop_sales
GROUP BY month_name;

-- CASE STATEMENTS - Time buckets
SELECT  transaction_time,
        DATE_FORMAT(transaction_time, 'hh:mm:ss') AS clean_time,
        CASE
        WHEN HOUR(transaction_time) BETWEEN 6 AND 10 THEN 'Morning'
        WHEN HOUR(transaction_time) BETWEEN 10 AND 13 THEN 'Afternoon'
        WHEN HOUR(transaction_time) BETWEEN 10 AND 13 THEN 'Late Afternoon'
        ELSE 'Evening'
        END AS time_bucket
FROM bright_coffee_shop_sales;

SELECT DAYNAME(transaction_date),
        DAYOFWEEK(transaction_date),
        CASE 
        WHEN DAYNAME(transaction_date) IN ('Sat', 'Sun') THEN 'Weekend'
        ELSE 'Weekday'
        END AS day_type
FROM bright_coffee_shop_sales;

--- FINAL BIG QUERY WITH ALL NEW COLUMNS

SELECT transaction_id,
        transaction_date,
        DATE_FORMAT(transaction_time, 'hh:mm:ss') AS clean_time, -- clean time (removes timestamp formatting)
        transaction_qty,
        store_id, 
        store_location,
        product_id,
        unit_price,
        product_category,
        product_type,
        product_detail,
        DAYNAME(transaction_date) AS day_name, -- Day name(Mon, Tue...)
        MONTHNAME(transaction_date) AS month_name, -- Month name(January, February...)
        DAYOFMONTH(transaction_date) AS day_number, --- Day of month(1-31)

        CASE 
        WHEN DAYNAME(transaction_date) IN ('Sat', 'Sun') THEN 'Weekend'
        ELSE 'Weekday'
        END AS day_type, -- Weekend vs weekday

        CASE
        WHEN HOUR(transaction_time) BETWEEN 6 AND 10 THEN 'Morning'
        WHEN HOUR(transaction_time) BETWEEN 10 AND 13 THEN 'Afternoon'
        WHEN HOUR(transaction_time) BETWEEN 10 AND 13 THEN 'Late Afternoon'
        ELSE 'Evening'
        END AS time_bucket, -- time bucket

        CASE
        WHEN DAYOFMONTH(transaction_date) BETWEEN 1 AND 10 THEN 'Early Month'
        WHEN DAYOFMONTH(transaction_date) BETWEEN 11 AND 20 THEN 'Mid Month'
        ELSE 'Month End'
        END AS month_period, -- month_period bucket
        
        CASE
        WHEN CAST(REPLACE(unit_price,',','.') AS DOUBLE) * CAST(transaction_qty AS DOUBLE) <=50 THEN 'Cheap spend'
        WHEN CAST(REPLACE(unit_price,',','.') AS DOUBLE) * CAST(transaction_qty AS DOUBLE) BETWEEN 51 AND 200 THEN 'Low spend'
        ELSE 'Expensive spend'
        END AS spend_bucket, -- spend bucket

        CAST(REPLACE(unit_price,',','.') AS DOUBLE) AS clean_unit_price, -- clean numeric price
        ROUND(CAST(REPLACE(unit_price,',','.') AS DOUBLE) * CAST(transaction_qty AS DOUBLE), 2) AS revenue -- revenue per row
FROM bright_coffee_shop_sales;





