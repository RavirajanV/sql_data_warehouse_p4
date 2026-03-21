/*
=================================================================================================
Quality Checks
=================================================================================================
Script Purpose:
  This script performs quality check to validate the integrity, consistency, and accuracy of the 
  Gold Layer. These checks ensures:
  - Uniqueness of surrogate keys in dimension tables
  - Referencial integrity between fact and dimesnion tables
  - Validation of relationships in the data model for analytical purposes

Usage Notes:
  - Run these checks after data loading Silver layer.
  - Investigate and resolve any discrepencies faced during the checks.
==================================================================================================
*/

-- ==================================================================
-- Checking 'gold.dim_customers'
-- ==================================================================
-- Check for Duplicate Items from the joined table 
SELECT 
	customer_key,
	COUNT(*) AS duplicate_times
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1

-- ==================================================================
-- Checking 'gold.dim_products'
-- ==================================================================
SELECT 
	product_number,
	COUNT(*) AS no_of_duplicates
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1
-- ==================================================================
-- Checking 'gold.fact_sales'
-- ==================================================================
-- Check for gold.fact_sales
-- Check if all dimension tables can successfully join to the fact table
SELECT 
	* 
FROM gold.fact_sales AS gold_sales
LEFT JOIN gold.dim_customers AS gold_cust
ON gold_sales.customer_key = gold_cust.customer_key
WHERE gold_cust.customer_key IS NULL
