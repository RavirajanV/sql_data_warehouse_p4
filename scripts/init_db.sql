/*
====================================
	Create Database and Schemas
====================================
	Script Purpose:
		This script creates a new database named 'SQLDWHP4' after checking if it already exists.
		If the database exists, it will be dropped and recreated again. Additionally, scripts is set up
		with 'bronze', 'silver', 'gold'.

	WARNING:
		Running this script will drop the entire 'SQLDWHP4' database if it exists leading to permanent deletion.
		Proceed with caution and ensure you have proper backups before running this scripts.
*/
USE master;
GO -- Batch Separator

-- Drop and recreate 'SQLDWHP4' if already exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'SQLDWHP4')
BEGIN
	-- Disconnect the active connection and rollback any running transactions
	ALTER DATABASE SQLDWHP4 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	-- Permanently Deletes the Database
	DROP DATABASE SQLDWHP4
END;
GO

-- Create Database 'SQLDWHP4'
CREATE DATABASE SQLDWHP4;
GO

-- Change the Database to SQLDWHP4
USE SQLDWHP4;
GO

-- Create Schema's
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
