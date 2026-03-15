/*
====================================================
	Create Stored Procedure for Bronze Layer
=====================================================
	Script Purpose:
		This stored procedure loads data into the 'bronze' schema from external CSV files.
		It performs the following actions:
		- Truncates the bronze tables before loading data.
		- Uses the 'BULK INSERT' command to load data from csv files to bronze tables.
	
	Parameters:
		None.
		This stored procedure does not accept any parameters or return any values

	Usage Example:
		EXEC bronze.load_bronze;

=====================================================
*/
-- Create Stored Procedure
-- Hint: Save frequently used SQL code in stored procedures in database
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME;
	-- TRY SQL runs the TRY bloc, and if it fails, it runs the CATCH block to handle the error
	BEGIN TRY
		-- Add PRINTS:
		-- Add Prints to track execution, debug issues, and understand its flow
		PRINT '===============================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '===============================================================';

		PRINT '---------------------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '---------------------------------------------------------------';
		SET @start_time = GETDATE();
		-- Develop SQL Load Script
		-- Truncate crm_prd_info: Quickly delete all rows from a table, resetting it to an empty state
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT '>> Bulk Inserting Into: bronze.crm_cust_info';
		-- Bulk Insert --> csv file or txt file ---> into DB all-in-one
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\ADMIN\OneDrive\Desktop\BIA\Projects\SQL\DataWareHouse_Project-P3\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		-- DATEDIFF() --> Calculates the diff btn two dates, returns days, months or years
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------------';

		-- Check whether the data is inserted properly
		SELECT COUNT(*) AS no_of_rows FROM bronze.crm_cust_info;

		SET @start_time = GETDATE();
		-- Truncate crm_prd_info
		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;

		-- Bulk Insert --> csv file or txt file ---> into DB all-in-one
		PRINT '>> Bulk Inserting Into: bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\ADMIN\OneDrive\Desktop\BIA\Projects\SQL\DataWareHouse_Project-P3\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------------';

		-- Check whether the data is inserted properly
		SELECT COUNT(*) AS no_of_rows FROM bronze.crm_prd_info;

		SET @start_time = GETDATE();
		-- Truncate crm_sales_details
		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
	
		-- Bulk Insert --> csv file or txt file ---> into DB all-in-one
		PRINT '>> Bulk Inserting Into: bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\ADMIN\OneDrive\Desktop\BIA\Projects\SQL\DataWareHouse_Project-P3\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------------';

		-- Check whether the data is inserted properly
		SELECT COUNT(*) AS no_of_rows FROM bronze.crm_sales_details

		PRINT '---------------------------------------------------------------';
		PRINT ' Loading ERP Tables';
		PRINT '---------------------------------------------------------------';
		SET @start_time = GETDATE();
		-- Truncate erp_loc_a101
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		-- Bulk Insert --> csv file or txt file ---> into DB all-in-one
		PRINT '>> Bulk Inserting Into: bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\ADMIN\OneDrive\Desktop\BIA\Projects\SQL\DataWareHouse_Project-P3\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------------';

		-- Check whether the data is inserted properly
		SELECT COUNT(*) AS no_of_rows FROM bronze.erp_loc_a101;

		SET @start_time = GETDATE();
		-- Truncate erp_cust_az12
		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		-- Bulk Insert --> csv file or txt file ---> into DB all-in-one
		PRINT '>> Bulk Inserting Into: bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\ADMIN\OneDrive\Desktop\BIA\Projects\SQL\DataWareHouse_Project-P3\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------------';

		-- Check whether the data is inserted properly
		SELECT COUNT(*) AS no_of_rows FROM bronze.erp_cust_az12;

		SET @start_time = GETDATE();
		-- Truncate erp_px_cat_g1v2
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		-- Bulk Insert --> csv file or txt file ---> into DB all-in-one
		PRINT '>> Bulk Inserting Into: bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\ADMIN\OneDrive\Desktop\BIA\Projects\SQL\DataWareHouse_Project-P3\dbc9660c89a3480fa5eb9bae464d6c07\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '---------------------------------';

		-- Check whether the data is inserted properly
		SELECT COUNT(*) AS no_of_rows FROM bronze.erp_px_cat_g1v2;
	END TRY
	BEGIN CATCH
		PRINT '================================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Number' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error State' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=================================================='
	END CATCH
END
GO

-- Track ETL Duration: Helps to Identify bottlenecks, optimize performance, monitor trends, detect issues
-- Execute Stored Procedure for ingesting the data in the csv file to the bronze layer
EXEC bronze.load_bronze
GO
