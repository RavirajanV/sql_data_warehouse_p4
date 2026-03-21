/* 
=====================================================================================
	Stored Procedure: Load Silver Layer [ Bronze --> Silver ]
=====================================================================================
Script Purpose:
  This stored procedure performs the ETL process to populate the 'silver' schema tables from
  'bronze' schema.

Action Performed:
  Truncates Silver Tables,
  Inserts transformed and cleansed data from Bronze into Silver tables

Parameters:
  None
  This stored procedure does not accept any parameters or return any values

Usage:
  EXEC silver.load_silver;
*/

CREATE OR ALTER PROCEDURE silver.load_silver 
AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '=================================';
		PRINT 'Loading Silver Layer';
		PRINT '=================================';

		PRINT '---------------------------------';
		PRINT ' Loading CRM Tables';
		PRINT '---------------------------------';

		-- Loading silver.crm_cust_info
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATE Table: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> Insert Data into: Silver Layer of silver.crm_cust_info';
		-- Check for Nulls or Duplicates in Primary Key
		-- Expectation: No Result
		-- Primary Key must be unique and not null
		-- INSERT 
		-- silver.crm_cust_info
		INSERT INTO silver.crm_cust_info (
			cust_id,
			cust_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_data)
		SELECT
			cust_id,
			cust_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE 
				WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
				ELSE 'n/a'
			END AS cst_marital_status,
			CASE 
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				ELSE 'n/a'
			END AS cst_gndr,
			cst_create_data 
		FROM (
			SELECT
				*,
				ROW_NUMBER() OVER (
								PARTITION BY cust_id
								ORDER BY cst_create_data DESC
					  			) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cust_id IS NOT NULL
			)t	
		WHERE flag_last = 1;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds.';
		PRINT '>> --------------------';

		-- Count the number of rows ingested to the silver layer
		SELECT 
			COUNT(*) AS no_of_rows_in_silver
		FROM silver.crm_cust_info;

		-- Loading crm_prd_info
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATE Table: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> Insert Data into: Silver Layer of silver.crm_prd_info';
		-- INSERT 
		-- silver.crm_prd_info
		INSERT INTO silver.crm_prd_info (
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			prd_id,
			-- Derived Columns: Create new columns based on calculations or tranformatioins of existing ones
			REPLACE(SUBSTRING(prd_key, 1, 5),'-','_') AS cat_id,
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
			prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost,
			CASE UPPER(TRIM(prd_line))
				 WHEN 'M' THEN 'Mountain'
				 WHEN 'R' THEN 'Road'
				 WHEN 'S' THEN 'Other Sales'
				 WHEN 'T' THEN 'Touring'
				 ELSE 'n/a'
			END AS prd_line,
			CAST(prd_start_dt AS DATE) AS prd_start_dt,
			-- Data Enrichment: Add new, relevant data to enhance the dataset for analysis
			CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt
		FROM bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds.';
		PRINT '>> --------------------';

		-- Count the number of rows ingested to the silver layer
		SELECT 
			COUNT(*) AS no_of_rows_in_silver
		FROM silver.crm_prd_info;

		-- Loading silver.crm_sales_details
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATE Table: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> Insert Data into: Silver Layer of silver.crm_sales_details';
		-- INSERT the data's into the sales details table
		INSERT INTO silver.crm_sales_details (
			sls_ord_num,
			sls_prod_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		-- Clean the sales details
		-- Rules
		-- If Sales is negative, zero or null derive it using Quantity and Price
		-- If Price is zero or null, calculate it using Sales and Quantity
		-- If Price is negative, convert it to a positive value
		-- crm_sales_details
		SELECT 
			sls_ord_num,
			sls_prod_key,
			sls_cust_id,
			CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
					THEN sls_quantity * ABS(sls_price)
				 ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE WHEN sls_price IS NULL OR sls_price <= 0
				   THEN sls_sales / NULLIF(sls_quantity, 0)
				 ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds.';
		PRINT '>> --------------------';

		-- Count the number of rows ingested to the silver layer
		SELECT 
			COUNT(*) AS no_of_rows_in_silver
		FROM silver.crm_sales_details;

		PRINT '---------------------------------';
		PRINT ' Loading ERP Tables';
		PRINT '---------------------------------';

		-- Loading erp_cust_az12
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATE Table: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>> Insert Data into: Silver Layer of silver.erp_cust_az12';
		-- INSERT the data's into the erp customer info
		INSERT INTO silver.erp_cust_az12 (
			cid,
			bdate,
			gen
		)
		-- Cleaned Data of erp_cust_az12
		SELECT 
			CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
				 ELSE cid
			END AS cid,
			CASE WHEN bdate > GETDATE() THEN NULL
				 ELSE bdate
			END AS bdate,
			CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
					WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
					ELSE 'n/a'
			END AS gen
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds.';
		PRINT '>> --------------------';

		-- Count the number of rows ingested to the silver layer
		SELECT 
			COUNT(*) AS no_of_rows_in_silver
		FROM silver.erp_loc_a101;

		-- Loading erp_loc_a101
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATE Table: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> Insert Data into: Silver Layer of silver.erp_loc_a101';
		-- Insert into silver.erp_loc_a101
		INSERT INTO silver.erp_loc_a101(
			cid,
			cntry
		)
		-- Clean the silver.erp_loc_a101
		-- Check details for erp_loc_a101
		SELECT 
			REPLACE(cid, '-', '') AS cid,
			CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				 WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
				 WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
				 ELSE TRIM(cntry)
			END AS cntry
		FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds.';
		PRINT '>> --------------------';

		-- Count the number of rows ingested to the silver layer
		SELECT 
			COUNT(*) AS no_of_rows_in_silver
		FROM silver.erp_cust_az12;

		-- Loading erp_px_cat_g1v2
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATE Table: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>> Insert Data into: Silver Layer of silver.erp_px_cat_g1v2';
		-- Insert data of bronze to silver layer
		INSERT INTO silver.erp_px_cat_g1v2 (
			id,
			cat,
			subcat,
			maintenance
		)
		-- Clean the data of silver.px_cat_g1v2
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds.';
		PRINT '>> --------------------';

		PRINT '>> ==============================';
		SET @batch_end_time = GETDATE();
		PRINT '>> Load Silver Layer';
		PRINT '>> Batch Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds.';
		PRINT '>> ==============================';

		-- Count the number of rows ingested to the silver layer
		SELECT 
			COUNT(*) AS no_of_rows_in_silver
		FROM silver.erp_px_cat_g1v2;
	END TRY
	BEGIN CATCH
		PRINT '================================================='
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Number' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=================================================='
	END CATCH
END
GO

-- Execute Stored Procedure for ingesting the data from the bronze layer to the silver layer
EXEC silver.load_silver
GO
