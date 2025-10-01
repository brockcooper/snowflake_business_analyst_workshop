-- Snowflake Business Analyst Workshop - Hands-on Lab (Answers)
-- Dataset: snowflake_public_data_free.public_data_free.us_economic_census_timeseries

-- Context setup (adjust as needed):
USE ROLE sysadmin;
USE WAREHOUSE compute_wh;
USE DATABASE snowflake_public_data_free;
USE SCHEMA public_data_free;

/* ================================================
   SELECT
   ================================================ */

-- Example 1: Basic SELECT specific columns
SELECT GEO_ID, VARIABLE, DATE, VALUE
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
LIMIT 100;

-- Example 2: SELECT all columns
SELECT *
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
LIMIT 100;

-- Practice: Select GEO_ID, DATE, and VALUE
-- Your answer:



/* ================================================
   DISTINCT
   ================================================ */

-- Example 1: DISTINCT VARIABLE_NAME
SELECT DISTINCT VARIABLE_NAME
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
LIMIT 100;

-- Example 2: DISTINCT UNIT values
SELECT DISTINCT UNIT
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries;

-- Practice 1: List distinct GEO_ID values (limit 50)
-- Your answer:


-- Practice 2: List distinct years from DATE
-- Hint: YEAR(DATE::DATE) or TO_CHAR(DATE::DATE,'YYYY')
-- Your answer:



/* ================================================
   WHERE
   ================================================ */

-- Example 1: Filter by exact UNIT
SELECT VARIABLE_NAME, UNIT, VALUE
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
WHERE UNIT = 'USD'
LIMIT 10;

-- Example 2: Filter by exact DATE
SELECT GEO_ID, VARIABLE, DATE, VALUE
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
WHERE DATE = '2017-12-31'
LIMIT 10;

-- Practice: Show VARIABLE and VALUE for DATE = '2012-12-31'
-- Your answer:



/* ================================================
   AND / OR
   ================================================ */

-- Example 1: UNIT = 'USD' AND DATE = '2017-12-31'
SELECT DATE, UNIT, VARIABLE_NAME, VALUE
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
WHERE UNIT = 'USD' AND DATE = '2017-12-31'
LIMIT 10;

-- Example 2: UNIT = 'USD' OR UNIT = 'Percent'
SELECT GEO_ID, UNIT, VALUE
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
WHERE UNIT = 'USD' OR UNIT = 'Percent'
LIMIT 10;

-- Practice 1: Show rows where DATE = '2017-12-31' AND UNIT = 'Percent'
-- Your answer:


-- Practice 2: Show rows where DATE = '2017-12-31' OR DATE = '2012-12-31'
-- Your answer:



/* ================================================
   IN
   ================================================ */

-- Example 1: UNIT IN ('USD','Percent')
SELECT UNIT, COUNT(*) AS row_count
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
WHERE UNIT IN ('USD','Percent')
GROUP BY UNIT;

-- Example 2: DATE IN specific list
SELECT DATE, COUNT(*) AS row_count
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
WHERE DATE IN ('2012-12-31','2017-12-31')
GROUP BY DATE
ORDER BY DATE;

-- Practice: Show rows where DATE = '2017-12-31' OR DATE = '2012-12-31' but using IN
-- Your answer:



/* ================================================
   BETWEEN
   ================================================ */

-- Note: BETWEEN works on comparable types; here we'll use VALUE numerics

-- Example 1: VALUE BETWEEN 0 AND 1000
SELECT VARIABLE_NAME, VALUE, UNIT
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
WHERE VALUE BETWEEN 0 AND 1000
LIMIT 10;

-- Example 2: VALUE BETWEEN 100000 AND 10000000
SELECT VARIABLE_NAME, VALUE, UNIT
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
WHERE VALUE BETWEEN 100000 AND 10000000
LIMIT 10;

-- Practice 1: Show rows where VALUE BETWEEN 1 AND 100
-- Your answer:


-- Practice 2: Count rows where VALUE BETWEEN 0 AND 0 (i.e., equals zero)
-- Your answer:


/* ================================================
   LIKE
   ================================================ */

-- Example 1: VARIABLE_NAME contains 'payroll'
SELECT VARIABLE_NAME, UNIT, VALUE
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
WHERE LOWER(VARIABLE_NAME) LIKE '%payroll%'
LIMIT 10;

-- Example 2: GEO_ID starts with 'geoId/12'
SELECT GEO_ID, VARIABLE, DATE
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
WHERE GEO_ID LIKE 'geoId/12%'
LIMIT 10;

-- Practice 1: Find VARIABLE_NAME containing 'chiropractor'
-- Your answer:


-- Practice 2: Find VARIABLEs that start with 'PAY'
-- Hint: Consider UPPER(VARIABLE) and LIKE 'PAY%'
-- Your answer:


/* ================================================
   NULL / NOT NULL
   ================================================ */

-- Example 1: VALUE IS NULL
SELECT *
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
WHERE VALUE IS NULL
LIMIT 10;

-- Example 2: UNIT IS NOT NULL
SELECT VARIABLE_NAME, UNIT
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
WHERE UNIT IS NOT NULL
LIMIT 10;

-- Practice: Show rows where VARIABLE_NAME IS NULL
-- Your answer:



/* ================================================
   ORDER BY
   ================================================ */

-- Example 1: ORDER BY VALUE DESC
SELECT VARIABLE_NAME, VALUE, UNIT
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
ORDER BY VALUE DESC
LIMIT 10;

-- Example 2: ORDER BY DATE ASC, VARIABLE ASC
SELECT GEO_ID, VARIABLE, DATE, VALUE
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
ORDER BY DATE ASC, VARIABLE ASC
LIMIT 10;

-- Practice: Show top 10 USD rows by VALUE
-- Your answer:



/* ================================================
   GROUP BY with Aggregate Functions
   ================================================ */

-- Example 1: Sum VALUE by UNIT
SELECT UNIT, SUM(VALUE) AS total_value
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
GROUP BY UNIT
ORDER BY total_value DESC;

-- Example 2: Count rows per DATE
SELECT DATE, COUNT(*) AS row_count
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
GROUP BY DATE
ORDER BY DATE;

-- Practice: For UNIT='USD', sum VALUE by DATE and variable_name and order by largest first
-- Your answer:



/* ================================================
   HAVING
   ================================================ */

-- Example 1: Keep only UNIT groups with total_value > 1,000,000
SELECT UNIT, SUM(VALUE) AS total_value
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
GROUP BY UNIT
HAVING SUM(VALUE) > 10000000
ORDER BY total_value DESC;

-- Example 2: Keep DATEs with more than 100 rows
SELECT DATE, COUNT(*) AS row_count
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
GROUP BY DATE
HAVING COUNT(*) > 100
ORDER BY DATE;


-- Practice: For VARIABLE ILIKE 'RCPTOT_444130%', show the total VALUE summed by GEO_ID, VARIABLE_NAME, and DATE.
-- Only include groups where the total VALUE is greater than 2,000,000,000. Order by total_value descending.
-- Your answer:



/* ================================================
   CASE STATEMENT
   ================================================ */

-- Example 1: Categorize VALUE magnitude
-- Business question: How are annual payroll values distributed for 2017, in USD, across different size buckets?
SELECT VARIABLE_NAME, VALUE, 
       CASE
         WHEN VALUE >= 100000000 THEN 'very_large'
         WHEN VALUE >= 1000000 THEN 'large'
         WHEN VALUE >= 10000 THEN 'medium'
         WHEN VALUE > 0 THEN 'small'
         WHEN VALUE = 0 THEN 'zero'
         ELSE 'negative_or_null'
       END AS value_bucket
FROM snowflake_public_data_free.public_data_free.us_economic_census_timeseries
WHERE VARIABLE_NAME ILIKE '%annual payroll%'
  AND UNIT = 'USD'
  AND DATE = '2017-12-31'
  AND value_bucket IN ('large', 'small')
ORDER BY VALUE DESC
;

-- Practice 1: Bucket by DATE YEAR(DATE::DATE) < 2020: 'pre-covid' vs 'post-covid'
-- Your answer:


-- Practice 2: Label VARIABLE_NAME ILIKE 'inventor%' as 'inventory' else 'other' 
-- then sum up the USD VALUE for that new column by the DATE in DESC order
-- Your answer:


/* ================================================
   JOINS
   ================================================ */

-- We'll join `geography_index` (geo names) to the census time series on GEO_ID
-- Tables:
--   snowflake_public_data_free.public_data_free.geography_index                 (gi)
--   snowflake_public_data_free.public_data_free.us_economic_census_timeseries   (c)

-- Example 1: LEFT JOIN to add geo names to census rows (base query)
SELECT gi.GEO_NAME,
       c.VARIABLE_NAME,
       c.VALUE,
       c.UNIT
FROM snowflake_public_data_free.public_data_free.geography_index AS gi
LEFT JOIN snowflake_public_data_free.public_data_free.us_economic_census_timeseries AS c
  ON gi.GEO_ID = c.GEO_ID
WHERE gi.GEO_NAME = 'Colorado'
ORDER BY c.VARIABLE_NAME;

-- Practice: Find some interesting insights about Colorado!
-- Your answer:



/* ================================================
   VIEWS
   ================================================ */

-- First, let's create a new database to put our work in:
CREATE DATABASE IF NOT EXISTS analytics;
CREATE SCHEMA IF NOT EXISTS analytics.census;

-- Example 1: Create a view for Colorado census rows
CREATE OR REPLACE VIEW analytics.census.colorado_census_view AS
SELECT gi.GEO_NAME,
       c.DATE,
       c.VARIABLE_NAME,
       c.VALUE,
       c.UNIT
FROM snowflake_public_data_free.public_data_free.geography_index AS gi
LEFT JOIN snowflake_public_data_free.public_data_free.us_economic_census_timeseries AS c
  ON gi.GEO_ID = c.GEO_ID
WHERE gi.GEO_NAME = 'Colorado'
ORDER BY c.VARIABLE_NAME;

-- Example 2: Query the view
SELECT * 
FROM analytics.census.colorado_census_view 
LIMIT 20;

-- Practice: Turn your query from the JOINs section into a view!
-- Your answer:
--


