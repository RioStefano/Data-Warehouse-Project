/*
===============================================================================
Stored Procedure: silver.load_silver (Bronze -> Silver)
===============================================================================
Description:
    Executes the ETL process to refresh the Silver layer using cleaned and 
    standardized data extracted from the Bronze schema.

Key Operations:
    - Clears target tables in the Silver schema via TRUNCATE.
    - Applies data cleaning, type casting, and duplicate removal.
    - Loads transformed datasets from Bronze into Silver tables.

Parameters:
    - None.

Execution:
    EXEC silver.load_silver;
===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME, @silver_start_time DATETIME, @silver_end_time DATETIME
	BEGIN TRY
		SET @silver_start_time = GETDATE()
		SET @batch_start_time = GETDATE()
		PRINT '----------------------------------------------'
		PRINT 'Loading Silver Layer'
		PRINT '----------------------------------------------'

		PRINT '----------------------------------------------'
		PRINT 'Loading CRM Tables'
		PRINT '----------------------------------------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.crm_customer_reviews'
		TRUNCATE TABLE silver.crm_customer_reviews
		PRINT '>> Inserting Data Into: silver.crm_customer_reviews'

		INSERT INTO silver.crm_customer_reviews (
			review_id,
			order_id,
			rating,
			food_rating,
			delivery_rating,
			review_text,
			created_at
		)
		SELECT 
			review_id, 
			order_id,
			CASE 
				WHEN rating > 5 THEN 5
				WHEN rating < 0 THEN ABS(rating)
				ELSE rating -- adjust 999 rating or negative rating
			END AS rating,
			CASE 
				WHEN food_rating > 5 THEN 5
				WHEN food_rating < 0 THEN ABS(food_rating)
				ELSE food_rating 
			END AS food_rating,
			CASE 
				WHEN delivery_rating > 5 THEN 5
				WHEN delivery_rating < 0 THEN (delivery_rating)
				ELSE delivery_rating
			END AS delivery_rating,
			TRIM(REPLACE(review_text, '@', '')) AS review_text,
			created_at
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY review_id ORDER BY created_at) AS flag
			FROM bronze.crm_customer_reviews
		) t
		WHERE flag = 1; --filter duplicate

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '------------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.crm_customers'
		TRUNCATE TABLE silver.crm_customers
		PRINT '>> Inserting Data Into: silver.crm_customers'

		INSERT INTO silver.crm_customers (
			customer_id,
			customer_name,
			city,
			phone,
			age_group,
			birthdate,
			gender,
			created_at,
			tier
		)
		SELECT 
			customer_id,
			(
				SELECT STRING_AGG(UPPER(LEFT(value, 1)) + LOWER(SUBSTRING(value, 2, LEN(value))), ' ')
				FROM STRING_SPLIT(TRIM(REPLACE(customer_name, '#', '')), ' ')
			) AS customer_name,
			city,
			TRIM(REPLACE(phone, '!', '')) AS phone,
			TRIM(REPLACE(age_group, '!', '')) AS age_group,
			CAST(birthdate AS DATE) AS birthdate,
			TRIM(REPLACE(gender, '@', '')) AS gender,
			created_at,
			UPPER(LEFT(tier, 1)) + LOWER(SUBSTRING(tier, 2, LEN(tier))) AS tier
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY created_at) AS flag
			FROM bronze.crm_customers
		) t
		WHERE flag = 1;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '------------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.crm_delivery_logs'
		TRUNCATE TABLE silver.crm_delivery_logs
		PRINT '>> Inserting Data Into: silver.crm_delivery_logs'

		INSERT INTO silver.crm_delivery_logs (
			delivery_id,
			order_id,
			delivery_partner_id,
			assigned_at,
			picked_at,
			delivered_at,
			distance_km
		)
		SELECT 
			delivery_id,
			order_id,
			delivery_partner_id,
			assigned_at,
			picked_at,
			delivered_at,
			distance_km
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY delivery_id ORDER BY delivered_at DESC) AS flag
			FROM bronze.crm_delivery_logs
		) t
		WHERE flag = 1;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '------------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.crm_order_items'
		TRUNCATE TABLE silver.crm_order_items
		PRINT '>> Inserting Data Into: silver.crm_order_items'

		INSERT INTO silver.crm_order_items (
			order_item_id,
			order_id,
			item_id,
			quantity,
			unit_price,
			line_total
		)
		SELECT 
			order_item_id,
			order_id,
			item_id,
			quantity,
			unit_price,
			line_total
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY order_item_id ORDER BY order_item_id) AS flag
			FROM bronze.crm_order_items
		) t
		WHERE flag = 1;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '------------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.crm_orders'
		TRUNCATE TABLE silver.crm_orders
		PRINT '>> Inserting Data Into: silver.crm_orders'

		INSERT INTO silver.crm_orders (
			order_id,
			customer_id,
			restaurant_id,
			order_datetime,
			payment_mode,
			order_status,
			cancel_stage,
			cancel_reason,
			delivery_partner_id,
			promo_id,
			discount_amount,
			delivery_fee
		)
		SELECT 
			order_id,
			customer_id,
			restaurant_id, 
			order_datetime,
			CASE 
				WHEN payment_mode IS NULL OR payment_mode = 'None' THEN 'N/A'
				WHEN payment_mode = 'wallet' THEN 'Wallet'
				WHEN payment_mode = 'cash' THEN 'Cash'
				WHEN payment_mode = 'upi' THEN 'UPI'
				WHEN payment_mode = 'card' THEN 'Card'
				ELSE payment_mode
			END AS payment_mode,
			CASE REPLACE(order_status, '@', '')
				WHEN 'completed' THEN 'Completed'
				WHEN 'cancelled' THEN 'Cancelled'
				WHEN 'failed' THEN 'Failed'
				ELSE 'N/A'
			END AS order_status,
			CASE 
				WHEN cancel_stage IS NULL OR cancel_stage = 'none' THEN 'N/A'
				WHEN cancel_stage = 'before_prepare' THEN 'Before Prepare'
				WHEN cancel_stage = 'after_prepare' THEN 'After Prepare'
				WHEN cancel_stage = 'out_for_delivery' THEN 'Out for Delivery'
				ELSE cancel_stage
			END AS cancel_stage,
			CASE 
				WHEN cancel_reason LIKE 'restaurant_issue%' THEN 'Restaurant Issue'
				WHEN cancel_reason LIKE 'user_cancel%' THEN 'User Cancel'
				WHEN cancel_reason LIKE 'delay%' THEN 'Delay'
				ELSE 'N/A'
			END AS cancel_reason,
			delivery_partner_id,
			CASE    
				WHEN promo_id LIKE '%@%' THEN TRIM(REPLACE(promo_id, '@', ''))
				WHEN promo_id IS NULL OR promo_id = 'None' THEN COALESCE(LOWER(TRIM(promo_id)), 'N/A') -- null caused by cancelled
				ELSE promo_id
			END AS promo_id,
			discount_amount,
			CASE
				WHEN delivery_fee < 0 THEN 0
				ELSE delivery_fee
			END AS delivery_fee
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_datetime DESC) AS flag
			FROM bronze.crm_orders
		) t
		WHERE flag = 1;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '------------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.crm_promotions'
		TRUNCATE TABLE silver.crm_promotions
		PRINT '>> Inserting Data Into: silver.crm_promotions'

		INSERT INTO silver.crm_promotions (
			promo_id,
			promo_name,
			discount_type,
			discount_value,
			min_order_value,
			valid_from,
			valid_to,
			is_active
		)
		SELECT 
			TRIM(REPLACE(promo_id, '@', '')) AS promo_id,
			promo_name,
			CASE 
				WHEN discount_type LIKE 'percent%' THEN 'Percent'
				WHEN discount_type LIKE 'flat%'    THEN 'Flat'
				ELSE 'N/A'
			END AS discount_type,
			CASE
				WHEN discount_value < 0 THEN 0 -- if ABS(discount_value) only $1 discount, doesnt make any sense
				ELSE discount_value
			END AS discount_value,
			CASE 
				WHEN min_order_value > 1000 THEN 100 -- doesnt make sense min order 99999, change into MIN(min_order_value)=100
				ELSE min_order_value
			END AS min_order_value,
			valid_from,
			valid_to,
			CASE 
				WHEN is_active = 1 THEN 'Yes'
				WHEN is_active = 0 THEN 'No'
				ELSE NULL
			END AS is_active
		FROM [bronze].[crm_promotions];

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '------------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.crm_refunds'
		TRUNCATE TABLE silver.crm_refunds
		PRINT '>> Inserting Data Into: silver.crm_refunds'

		INSERT INTO silver.crm_refunds (
			refund_id,
			order_id,
			refund_reason,
			refund_type,
			refund_amount,
			refund_method,
			refund_status,
			initiated_at,
			processed_at
		)
		SELECT 
			refund_id,
			order_id,
			CASE 
				WHEN refund_reason LIKE 'delay%' THEN 'Delay'
				WHEN refund_reason LIKE 'user_cancel%' THEN 'User Cancel'
				WHEN refund_reason LIKE 'restaurant_issue%' THEN 'Restaurant Issue'
				ELSE 'N/A'
			END AS refund_reason,
			CASE 
				WHEN refund_type LIKE 'partial%' THEN 'Partial'
				WHEN refund_type LIKE 'full%' THEN 'Full'
				ELSE 'N/A'
			END AS refund_type,
			refund_amount,
			CASE 
				WHEN refund_method LIKE 'wallet%' THEN 'Wallet'
				WHEN refund_method LIKE 'card%' THEN 'Card'
				WHEN refund_method LIKE 'cash%' THEN 'Cash'
				WHEN refund_method LIKE 'upi%' THEN 'UPI'
				ELSE 'N/A'
			END AS refund_method,
			CASE 
				WHEN refund_status LIKE 'pending%' THEN 'Pending'
				WHEN refund_status LIKE 'processed%' THEN 'Processed'
				WHEN refund_status LIKE 'failed%' THEN 'Failed'
				ELSE 'N/A'
			END AS refund_status,
			initiated_at,
			processed_at
		FROM bronze.crm_refunds;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '------------------'

		SET @batch_end_time = GETDATE()
		PRINT '~~~~~~~~~~~~~~~'
		PRINT '>> Load CRM Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds'
		PRINT '~~~~~~~~~~~~~~~'

		SET @batch_start_time = GETDATE()
		PRINT '----------------------------------------------'
		PRINT 'Loading ERP Tables'
		PRINT '----------------------------------------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.erp_delivery_partners'
		TRUNCATE TABLE silver.erp_delivery_partners
		PRINT '>> Inserting Data Into: silver.erp_delivery_partners'

		INSERT INTO silver.erp_delivery_partners (
			delivery_partner_id,
			name,
			partner_type,
			vehicle_type,
			phone,
			join_date,
			avg_rating,
			is_active
		)
		SELECT 
			delivery_partner_id,
			(
				SELECT STRING_AGG(UPPER(LEFT(value, 1)) + LOWER(SUBSTRING(value, 2, LEN(value))), ' ')
				FROM STRING_SPLIT(TRIM(name), ' ')
			) AS name,
			CASE
				WHEN partner_type = 'in_house' THEN 'In House'
				WHEN partner_type = 'third_party' THEN 'Third Party'
				ELSE partner_type
			END AS partner_type,
			CASE
				WHEN vehicle_type LIKE 'bike%' THEN 'Bike'
				WHEN vehicle_type LIKE 'scooter%' THEN 'Scooter'
				ELSE 'N/A'
			END AS vehicle_type,
			phone,
			COALESCE(
				TRY_PARSE(TRIM(REPLACE(join_date, '!', '')) AS DATE USING 'en-US'), --there are some MMM DD YYYY format
				TRY_PARSE(TRIM(REPLACE(join_date, '!', '')) AS DATE USING 'en-GB') --there is a DD-MM-YYYY
			) AS join_date,
			CASE 
				WHEN avg_rating > 5 THEN 5
				WHEN avg_rating IS NULL THEN 3 --assume null value is MIN(avg_rating) 
				ELSE avg_rating
			END AS avg_rating,
			CASE 
				WHEN is_active = 1 THEN 'Yes'
				WHEN is_active = 0 THEN 'No'
				ELSE 'N/A' 
			END AS is_active
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY delivery_partner_id ORDER BY join_date DESC) AS flag
			FROM bronze.erp_delivery_partners
		) t
		WHERE flag = 1;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '------------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.erp_employees'
		TRUNCATE TABLE silver.erp_employees
		PRINT '>> Inserting Data Into: silver.erp_employees'

		INSERT INTO silver.erp_employees (
			emp_id,
			name,
			restaurant_id,
			role,
			hire_date,
			salary
		)
		SELECT 
			emp_id,
			(
				SELECT STRING_AGG(UPPER(LEFT(value, 1)) + LOWER(SUBSTRING(value, 2, LEN(value))), ' ')
				FROM STRING_SPLIT(TRIM(name), ' ')
			) AS name,
			restaurant_id,
			CASE 
				WHEN role LIKE 'cashier%' THEN 'Cashier'
				WHEN role LIKE 'chef%'    THEN 'Chef'
				WHEN role LIKE 'helper%'  THEN 'Helper'
				WHEN role LIKE 'manager%' THEN 'Manager'
				WHEN role IS NULL AND salary <= 15942.63 THEN 'Helper'
				WHEN role IS NULL AND salary <= 21594.90 THEN 'Cashier'
				WHEN role IS NULL AND salary <= 38041.26 THEN 'Chef'
				WHEN role IS NULL AND salary < 99999     THEN 'Manager'
				ELSE 'N/A'
			END AS role,
			hire_date,
			CASE 
				WHEN salary = 99999 AND role = 'Helper'  THEN 19861
				WHEN salary = 99999 AND role = 'Cashier' THEN 27782
				WHEN salary = 99999 AND role = 'Chef'    THEN 49946
				WHEN salary = 99999 AND role = 'Manager' THEN 69644
				WHEN salary IS NULL AND role = 'Helper'  THEN 15942.63
				WHEN salary IS NULL AND role = 'Cashier' THEN 21594.90
				WHEN salary IS NULL AND role = 'Chef'    THEN 38041.26
				WHEN salary IS NULL AND role = 'Manager' THEN 54675.64
				ELSE salary
			END AS salary
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY emp_id ORDER BY hire_date DESC) AS flag
			FROM bronze.erp_employees
		) t
		WHERE flag = 1;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '------------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.erp_kitchen_logs'
		TRUNCATE TABLE silver.erp_kitchen_logs
		PRINT '>> Inserting Data Into: silver.erp_kitchen_logs'

		INSERT INTO silver.erp_kitchen_logs (
			kitchen_log_id,
			order_item_id,
			chef_id,
			started_at,
			completed_at,
			status
		)
		SELECT 
			kitchen_log_id,
			order_item_id,
			TRIM(REPLACE(chef_id, '#', '')) AS chef_id,
			started_at,
			completed_at,
			CASE 
				WHEN status LIKE 'wasted%'    THEN 'Wasted'
				WHEN status LIKE 'prepared%'  THEN 'Prepared'
				WHEN status LIKE 'cancelled%' THEN 'Cancelled'
				ELSE 'N/A'
			END AS status
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY kitchen_log_id ORDER BY completed_at DESC) AS flag
			FROM bronze.erp_kitchen_logs
		) t
		WHERE flag = 1;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '------------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.erp_menu_items'
		TRUNCATE TABLE silver.erp_menu_items
		PRINT '>> Inserting Data Into: silver.erp_menu_items'

		INSERT INTO silver.erp_menu_items (
			item_id,
			item_name,
			category,
			cuisine,
			is_veg,
			is_available,
			selling_price
		)
		SELECT 
			item_id,
			item_name,
			TRIM(REPLACE(category, '!', '')) AS category,
			TRIM(REPLACE(cuisine, '#', '')) AS cuisine,
			CASE 
				WHEN is_veg = 1 THEN 'Yes'
				WHEN is_veg = 0 THEN 'No'
				ELSE 'N/A' 
			END AS is_veg,
			CASE 
				WHEN is_available = 1 THEN 'Yes'
				WHEN is_available = 0 THEN 'No'
				ELSE 'N/A' 
			END AS is_available,
			selling_price
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY item_id ORDER BY selling_price) AS flag
			FROM bronze.erp_menu_items
		) t
		WHERE flag = 1;

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '------------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: silver.erp_restaurants'
		TRUNCATE TABLE silver.erp_restaurants
		PRINT '>> Inserting Data Into: silver.erp_restaurants'

		INSERT INTO silver.erp_restaurants (
			restaurant_id,
			restaurant_name,
			city,
			restaurant_type,
			open_date,
			is_active,
			closed_date
		)
		SELECT 
			restaurant_id,
			TRIM(REPLACE(restaurant_name, '@', '')) AS restaurant_name,
			city,
			restaurant_type,
			open_date,
			CASE 
				WHEN is_active = 1 THEN 'Yes'
				WHEN is_active = 0 THEN 'No'
				ELSE 'N/A' 
			END AS is_active,
			TRY_CAST(
				NULLIF(TRIM(closed_date), 'N/A') 
				AS DATE
			) AS closed_date
		FROM [bronze].[erp_restaurants];

		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds'
		PRINT '------------------'

		SET @batch_end_time = GETDATE()
		PRINT '~~~~~~~~~~~~~~~'
		PRINT '>> Load ERP Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds'
		PRINT '~~~~~~~~~~~~~~~'

		SET @silver_end_time = GETDATE()
		PRINT '=================================='
		PRINT 'Loading Silver Layer is Completed'
		PRINT '>> Total Load Duration: ' + CAST(DATEDIFF(second, @silver_start_time, @silver_end_time) AS NVARCHAR) + ' seconds'
		PRINT '=================================='
	END TRY
	BEGIN CATCH
		PRINT '=================================='
		PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER'
		PRINT 'Error Message: ' + ERROR_MESSAGE()
		PRINT 'Error Number:  ' + CAST(ERROR_NUMBER() AS NVARCHAR)
		PRINT 'Error State:   ' + CAST(ERROR_STATE() AS NVARCHAR)
		PRINT '=================================='
	END CATCH
END; 
GO

