/*
====================================
	Create Table for Bronze Layer
====================================
	Script Purpose:
		This script is to check the table exist, if yes drop and create a table for bronze layer.
    Run this script to re-define the DDL structure of 'bronze' tables.
*/ 
-- Check 'bronze.crm_cust_info' Table exists or not
IF OBJECT_ID ('bronze.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
GO

-- Table to create crm customer information
CREATE TABLE bronze.crm_cust_info (
	cust_id INT,
	cust_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_material_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_data DATE
);
GO

-- Check 'bronze.crm_prd_info' Table exists or not
IF OBJECT_ID ('bronze.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
GO

-- Table to create crm product information
CREATE TABLE bronze.crm_prd_info (
	prd_id		 INT,
	prd_key		 NVARCHAR(50),
	prd_nm		 NVARCHAR(50),
	prd_cost	 INT,
	prd_line	 NVARCHAR(50),
	prd_start_dt DATETIME,
	prd_end_dt	 DATETIME
);
GO

-- Check 'bronze.crm_sales_details' Table exists or not
IF OBJECT_ID ('bronze.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
GO

-- Table to create crm sales information
CREATE TABLE bronze.crm_sales_details (
	sls_ord_num NVARCHAR(50),
	sls_prod_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);
GO

-- Check 'bronze.erp_loc_a101' Table exists or not
IF OBJECT_ID ('bronze.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;
GO

-- Table erp location details
CREATE TABLE bronze.erp_loc_a101 (
	cid NVARCHAR(50),
	cntry NVARCHAR(50)
);
GO

-- Check 'bronze.erp_cust_az12' Table exists or not
IF OBJECT_ID ('bronze.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
GO

-- Table erp customer details
CREATE TABLE bronze.erp_cust_az12 (
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50)
);
GO

-- Check 'bronze.erp_px_cat_g1v2' Table exists or not
IF OBJECT_ID ('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;
GO

-- Table erp category details
CREATE TABLE bronze.erp_px_cat_g1v2 (
	id			NVARCHAR(50),
	cat			NVARCHAR(50),
	subcat		NVARCHAR(50),
	maintenance NVARCHAR(50)
);
GO
