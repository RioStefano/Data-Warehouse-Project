/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME, @bronze_start_time DATETIME, @bronze_end_time DATETIME;
	BEGIN TRY
		SET @bronze_start_time = GETDATE()
		SET @batch_start_time = GETDATE();
		PRINT '================================================';
		PRINT 'Loading Bronze Layer';
		PRINT '================================================';

		PRINT '------------------------------------------------';
		PRINT 'Loading CRM Tables';
		PRINT '------------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_customer_reviews';
		TRUNCATE TABLE bronze.crm_customer_reviews;
		PRINT '>> Inserting Data Into: bronze.crm_customer_reviews';
		BULK INSERT bronze.crm_customer_reviews
		FROM 'C:\Users\62813\OneDrive\Documents\Microsoft SQL Server\Data Warehouse Project\datasets\source_crm\customer_reviews.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_customers';
		TRUNCATE TABLE bronze.crm_customers;
		PRINT '>> Inserting Data Into: bronze.crm_customers';
		BULK INSERT bronze.crm_customers
		FROM 'C:\Users\62813\OneDrive\Documents\Microsoft SQL Server\Data Warehouse Project\datasets\source_crm\customers.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_delivery_logs';
		TRUNCATE TABLE bronze.crm_delivery_logs;
		PRINT '>> Inserting Data Into: bronze.crm_delivery_logs';
		BULK INSERT bronze.crm_delivery_logs
		FROM 'C:\Users\62813\OneDrive\Documents\Microsoft SQL Server\Data Warehouse Project\datasets\source_crm\delivery_logs.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_order_items';
		TRUNCATE TABLE bronze.crm_order_items;
		PRINT '>> Inserting Data Into: bronze.crm_order_items';
		BULK INSERT bronze.crm_order_items
		FROM 'C:\Users\62813\OneDrive\Documents\Microsoft SQL Server\Data Warehouse Project\datasets\source_crm\order_items.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_orders';
		TRUNCATE TABLE bronze.crm_orders;
		PRINT '>> Inserting Data Into: bronze.crm_orders';
		BULK INSERT bronze.crm_orders
		FROM 'C:\Users\62813\OneDrive\Documents\Microsoft SQL Server\Data Warehouse Project\datasets\source_crm\orders.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_promotions';
		TRUNCATE TABLE bronze.crm_promotions;
		PRINT '>> Inserting Data Into: bronze.crm_promotions';
		BULK INSERT bronze.crm_promotions
		FROM 'C:\Users\62813\OneDrive\Documents\Microsoft SQL Server\Data Warehouse Project\datasets\source_crm\promotions.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_refunds';
		TRUNCATE TABLE bronze.crm_refunds;
		PRINT '>> Inserting Data Into: bronze.crm_refunds';
		BULK INSERT bronze.crm_refunds
		FROM 'C:\Users\62813\OneDrive\Documents\Microsoft SQL Server\Data Warehouse Project\datasets\source_crm\refunds.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------';

		SET @batch_end_time = GETDATE()
		PRINT '~~~~~~~~~~~~~~~'
		PRINT '>> Load CRM Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds'
		PRINT '~~~~~~~~~~~~~~~'

		PRINT '------------------------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '------------------------------------------------';

		SET @batch_start_time = GETDATE()
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_delivery_partners';
		TRUNCATE TABLE bronze.erp_delivery_partners;
		PRINT '>> Inserting Data Into: bronze.erp_delivery_partners';
		BULK INSERT bronze.erp_delivery_partners
		FROM 'C:\Users\62813\OneDrive\Documents\Microsoft SQL Server\Data Warehouse Project\datasets\source_erp\delivery_partners.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_employees';
		TRUNCATE TABLE bronze.erp_employees;
		PRINT '>> Inserting Data Into: bronze.erp_employees';
		BULK INSERT bronze.erp_employees
		FROM 'C:\Users\62813\OneDrive\Documents\Microsoft SQL Server\Data Warehouse Project\datasets\source_erp\employees.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_kitchen_logs';
		TRUNCATE TABLE bronze.erp_kitchen_logs;
		PRINT '>> Inserting Data Into: bronze.erp_kitchen_logs';
		BULK INSERT bronze.erp_kitchen_logs
		FROM 'C:\Users\62813\OneDrive\Documents\Microsoft SQL Server\Data Warehouse Project\datasets\source_erp\kitchen_logs.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_menu_items';
		TRUNCATE TABLE bronze.erp_menu_items;
		PRINT '>> Inserting Data Into: bronze.erp_menu_items';
		BULK INSERT bronze.erp_menu_items
		FROM 'C:\Users\62813\OneDrive\Documents\Microsoft SQL Server\Data Warehouse Project\datasets\source_erp\menu_items.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_restaurants';
		TRUNCATE TABLE bronze.erp_restaurants;
		PRINT '>> Inserting Data Into: bronze.erp_restaurants';
		BULK INSERT bronze.erp_restaurants
		FROM 'C:\Users\62813\OneDrive\Documents\Microsoft SQL Server\Data Warehouse Project\datasets\source_erp\restaurants.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
		PRINT '------------------';

		SET @batch_end_time = GETDATE()
		PRINT '~~~~~~~~~~~~~~~'
		PRINT '>> Load ERP Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds'
		PRINT '~~~~~~~~~~~~~~~'

		SET @bronze_end_time = GETDATE()
		PRINT '=================================='
		PRINT 'Loading Bronze Layer is Completed'
		PRINT '>> Load Total Duration: ' + CAST(DATEDIFF(second, @bronze_start_time, @bronze_end_time) AS NVARCHAR) + ' seconds'
		PRINT '=================================='
	END TRY
	BEGIN CATCH
		PRINT '=================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE()
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '=================================='
	END CATCH
END
