/*
=============================================================================
Quality Checks
==============================================================================
Script Purpose:
  This script performs various quality checks for data consistency, accuracy,
  and standardization across the 'silver' schema. It includes checks for:
  - NULL or Duplicates Primary,
  - Unwanted spaces in string fields,
  - Data Standardization and Consistency
  - Invalid data ranges and orders,
  - Data Consistency between related fields.

Usage Notes:
  - Run these checks after data loading silver layer.
  - Investigate and resolve any discrepencies found during the checks

Consistency: 
	If you introduce an improvement, like better logging or 
	error handling, in one stored procedure, apply it to the
	others to maintain consistent standards and benefits.
=================================================================================
*/

-- ===============================================================================
-- Checking 'silver.crm_cust_info'
-- ================================================================================
-- Check the silver table for any uncleaned data
-- Duplicate Primary Key Check
SELECT cust_id, COUNT(*) FROM silver.crm_cust_info
GROUP BY cust_id
HAVING COUNT(*) > 1 OR cust_id IS NULL

-- Check for unwanted spaces
-- Expectations: No result
SELECT cst_lastname FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

-- Data Standardization & Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

-- ===============================================================================
-- Checking 'silver.crm_prd_info'
-- ================================================================================
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Result
SELECT
	prd_id,
	COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for any unwanted spaces in product name
SELECT
	prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for any zeros and null in product cost
SELECT
	prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Data Standardization & Consistency
SELECT DISTINCT prd_line
FROM silver.crm_prd_info

-- Check for Invalid Date Orders
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt

-- ===============================================================================
-- Checking 'silver.crm_sales_details'
-- ================================================================================
-- Check for Invalid dates
SELECT
	NULLIF(sls_ship_dt,0) AS sls_ship_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt <= 0
OR LEN(sls_ship_dt) != 8
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101

-- Check for Order Date
SELECT
	*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
OR sls_order_dt > sls_due_dt

--- Sales details 
SELECT DISTINCT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_sales IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

-- ===============================================================================
-- Checking 'silver.erp_cust_az12'
-- ================================================================================
-- Identify Out-Of-Range Dates
SELECT DISTINCT	
	bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()

-- Data Standardization & Consistency
SELECT DISTINCT gen,
	   CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
	        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
			ELSE 'n/a'
	   END AS gen_new
FROM silver.erp_cust_az12

-- ===============================================================================
-- Checking 'silver.erp_loc_a101'
-- ================================================================================
-- Check details for erp_loc_a101
SELECT 
	REPLACE(cid, '-', '') AS cid,
	CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	     WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
		 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		 ELSE TRIM(cntry)
	END AS cntry
FROM silver.erp_loc_a101

-- Data Standardization & Consistency
SELECT DISTINCT cntry AS old_cntry,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
	     WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
		 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
		 ELSE TRIM(cntry)
	END AS cntry
FROM silver.erp_loc_a101
ORDER BY cntry

-- ===============================================================================
-- Checking 'silver.px_cat_g1v2'
-- ================================================================================
-- Clean the data of silver.px_cat_g1v2
SELECT
	id,
	cat,
	subcat,
	maintenance
FROM silver.erp_px_cat_g1v2

-- Check for Unwanted Spaces
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
OR subcat != TRIM(subcat)
OR maintenance != TRIM(maintenance)

-- Data Standardization & Consistency
SELECT DISTINCT maintenance FROM silver.erp_px_cat_g1v2
