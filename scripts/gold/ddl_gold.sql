/*
========================================================
DDL Script: Create Gold Views
========================================================
Script Purpose:
  This script creates views for the Gold Layer in the data warehouse.
  The Gold layer represents the final dimension and fact tables ( Star Schema )

  Each view performs transformations and combines data from the Silver Layer
  to produce a clean, enriched and business-ready dataset.

Usage:
  These views can be queried directly for analytics and reporting.
*/
-- Surrogate Key: System-generated unique identifier assigned to each record in a table.
-- How to define surrogate key? DDL-based generation, Query-based using window function (Row_Number).
-- JOIN the crm customer table and erp customer table and location table
-- Naming conventions, English language, Avoid reserved words
-- crm_cust_info + erp_cust_az12 + erp_loc_a101

-- =============================================================
-- Create Dimensions: gold.dim_customers
-- =============================================================
-- Check 'gold.dim_customers' View exists or not
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
  DROP VIEW gold.dim_customers;
GO

-- silver.crm_cust_info + silver.erp_cust_az12 + silver.erp_loc_a101
CREATE VIEW gold.dim_customers 
AS
SELECT
	ROW_NUMBER() OVER (ORDER BY cust_id) AS customer_key,
	crm_cust.cust_id AS customer_id,
	crm_cust.cust_key AS customer_number,
	crm_cust.cst_firstname AS first_name,
	crm_cust.cst_lastname AS last_name,
	erp_loc.cntry AS country,
	crm_cust.cst_marital_status AS marital_status,
	CASE WHEN crm_cust.cst_gndr != 'n/a' THEN crm_cust.cst_gndr -- CRM is the Master for gender information
	     ELSE COALESCE(erp_cust.gen, 'n/a')
	END AS gender,
	erp_cust.bdate AS birth_date,
	crm_cust.cst_create_data AS create_date
FROM silver.crm_cust_info AS crm_cust
LEFT JOIN silver.erp_cust_az12 AS erp_cust
ON crm_cust.cust_key = erp_cust.cid
LEFT JOIN silver.erp_loc_a101 AS erp_loc
ON crm_cust.cust_key = erp_loc.cid;
GO

-- =============================================================
-- Create Dimensions: gold.dim_products
-- =============================================================
-- Check 'gold.dim_products' View exists or not
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
  DROP VIEW gold.dim_products;
GO

-- silver.crm_prd_info + silver.erp_px_cat_g1v2
CREATE VIEW gold.dim_products 
AS
SELECT
	ROW_NUMBER() OVER (ORDER BY crm_prd.prd_start_dt, crm_prd.prd_key) AS product_key,
	crm_prd.prd_id AS product_id,
	crm_prd.prd_key AS product_number,
	crm_prd.prd_nm AS product_name,
	crm_prd.cat_id AS category_id,
	erp_px.cat AS category,
	erp_px.subcat AS subcategory,
	erp_px.maintenance,
	crm_prd.prd_cost AS product_cost,
	crm_prd.prd_line AS product_line,
	crm_prd.prd_start_dt AS start_date
FROM silver.crm_prd_info AS crm_prd
LEFT JOIN silver.erp_px_cat_g1v2 AS erp_px
ON crm_prd.cat_id = erp_px.id
WHERE prd_end_dt IS NULL;-- Filter out all historical date
GO

-- =============================================================
-- Create Dimensions: gold.fact_sales
-- =============================================================
-- Check 'gold.fact_sales' View exists or not
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
  DROP VIEW gold.fact_sales;
GO

-- silver.crm_sales_details + silver.crm_cust_info + silver.crm_prd_info
CREATE VIEW gold.fact_sales
AS
SELECT
	crm_sales.sls_ord_num AS order_number,
	gold_prod.product_key AS product_key,
	gold_cust.customer_key AS customer_key,
	crm_sales.sls_order_dt AS order_date,
	crm_sales.sls_ship_dt AS shipping_date,
	crm_sales.sls_due_dt AS due_date,
	crm_sales.sls_sales AS sales_amount,
	crm_sales.sls_quantity AS quantity,
	crm_sales.sls_price AS price
FROM silver.crm_sales_details AS crm_sales
LEFT JOIN gold.dim_products AS gold_prod
ON crm_sales.sls_prod_key = gold_prod.product_number
LEFT JOIN gold.dim_customers AS gold_cust
ON crm_sales.sls_cust_id = gold_cust.customer_id;
GO
