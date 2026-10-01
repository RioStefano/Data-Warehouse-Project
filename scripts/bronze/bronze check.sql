-- ============================================================
SELECT * FROM [bronze].[crm_customer_reviews]

-- Check for duplicates
SELECT COUNT(*) FROM [bronze].[crm_customer_reviews]
GROUP BY review_id
HAVING COUNT(*) > 1

-- Check for null value
SELECT *
FROM [bronze].[crm_customer_reviews]
WHERE review_id IS NULL
   OR order_id IS NULL
   OR rating IS NULL
   OR food_rating IS NULL
   OR delivery_rating IS NULL
   OR review_text IS NULL
   OR created_at IS NULL;

--Check for extra spaces
SELECT DISTINCT LEN(order_id) FROM [bronze].[crm_customer_reviews]

--Check for extra type of data
SELECT DISTINCT delivery_rating from [bronze].[crm_customer_reviews]
SELECT DISTINCT review_text from [bronze].[crm_customer_reviews]

-- ============================================================

SELECT * FROM [bronze].[crm_customers]

-- Check for duplicates
SELECT COUNT(*) FROM [bronze].[crm_customers]
GROUP BY customer_id
HAVING COUNT(*) > 1

-- Check for null value
SELECT *
FROM bronze.crm_customers
WHERE 
    customer_id IS NULL
    OR customer_name IS NULL
    OR city IS NULL
    OR phone IS NULL
    OR age_group IS NULL
    OR birthdate IS NULL
    OR gender IS NULL
    OR created_at IS NULL
    OR tier IS NULL;

--Check for extra type of data
SELECT DISTINCT city from [bronze].[crm_customers]
SELECT DISTINCT age_group from [bronze].[crm_customers]
SELECT DISTINCT gender from [bronze].[crm_customers]
SELECT DISTINCT tier from [bronze].[crm_customers]

SELECT phone
FROM [bronze].[crm_customers]
WHERE phone LIKE '%[#@!]%';

-- ============================================================

SELECT * FROM [bronze].[crm_delivery_logs]

-- Check for duplicates
SELECT COUNT(*) FROM [bronze].[crm_delivery_logs]
GROUP BY delivery_id
HAVING COUNT(*) > 1

--Check for extra spaces
SELECT DISTINCT LEN(order_id) FROM [bronze].[crm_delivery_logs]
SELECT DISTINCT LEN(delivery_partner_id) FROM [bronze].[crm_delivery_logs]

-- Check for null value
SELECT *
FROM [bronze].[crm_delivery_logs]
WHERE delivery_id IS NULL
   OR order_id IS NULL
   OR delivery_partner_id IS NULL
   OR assigned_at IS NULL
   OR picked_at IS NULL
   OR delivered_at IS NULL
   OR distance_km IS NULL;

-- ============================================================

SELECT * FROM [bronze].[crm_order_items]

-- Check for duplicates
SELECT COUNT(*) FROM [bronze].[crm_order_items]
GROUP BY order_item_id
HAVING COUNT(*) > 1

--Check for extra spaces
SELECT DISTINCT LEN(order_item_id) FROM [bronze].[crm_order_items]
SELECT DISTINCT LEN(order_id) FROM [bronze].[crm_order_items]
SELECT DISTINCT LEN(item_id) FROM [bronze].[crm_order_items]

-- Check for null value
SELECT *
FROM [bronze].[crm_order_items]
WHERE order_item_id IS NULL
   OR order_id IS NULL
   OR item_id IS NULL
   OR quantity IS NULL
   OR unit_price IS NULL
   OR line_total IS NULL;

-- ============================================================

SELECT * FROM [bronze].[crm_orders]

-- Check for duplicates
SELECT COUNT(*) FROM [bronze].[crm_orders]
GROUP BY order_id
HAVING COUNT(*) > 1

-- Check for null value
SELECT *
FROM [bronze].[crm_orders]
WHERE order_id IS NULL
   OR customer_id IS NULL
   OR restaurant_id IS NULL
   OR order_datetime IS NULL
   OR payment_mode IS NULL
   OR order_status IS NULL
   OR cancel_stage IS NULL
   OR cancel_reason IS NULL
   OR delivery_partner_id IS NULL
   OR promo_id IS NULL
   OR discount_amount IS NULL
   OR delivery_fee IS NULL;

--Check for extra spaces
SELECT DISTINCT LEN(order_id) FROM [bronze].[crm_orders]
SELECT DISTINCT LEN(customer_id) FROM [bronze].[crm_orders]
SELECT DISTINCT LEN(restaurant_id) FROM [bronze].[crm_orders]
SELECT DISTINCT LEN(delivery_partner_id) FROM [bronze].[crm_orders]
SELECT DISTINCT LEN(promo_id) FROM [bronze].[crm_orders]

--Check for extra type of data
SELECT DISTINCT payment_mode FROM [bronze].[crm_orders]
SELECT DISTINCT order_status FROM [bronze].[crm_orders]
SELECT DISTINCT cancel_stage FROM [bronze].[crm_orders]
SELECT DISTINCT cancel_reason FROM [bronze].[crm_orders]
SELECT DISTINCT promo_id FROM [bronze].[crm_orders]

--Check negative value
SELECT discount_amount FROM [bronze].[crm_orders]
WHERE discount_amount < 0

-- ============================================================

SELECT * FROM [bronze].[crm_promotions]

-- Check for duplicates
SELECT COUNT(*) FROM [bronze].[crm_promotions]
GROUP BY promo_id
HAVING COUNT(*) > 1

--Check for extra spaces
SELECT DISTINCT LEN(promo_id) FROM [bronze].[crm_promotions]

--Check for extra type of data
SELECT DISTINCT promo_name FROM [bronze].[crm_promotions]
SELECT DISTINCT discount_type FROM [bronze].[crm_promotions]
SELECT DISTINCT discount_value FROM [bronze].[crm_promotions]

SELECT
    CASE
        WHEN discount_value < 0 THEN NULL
        ELSE discount_value
    END AS discount_value
FROM [bronze].[crm_promotions]

-- ============================================================

SELECT * FROM [bronze].[crm_refunds]

-- Check for duplicates
SELECT COUNT(*) FROM [bronze].[crm_refunds]
GROUP BY refund_id
HAVING COUNT(*) > 1

--Check for extra spaces
SELECT DISTINCT LEN(refund_id) FROM [bronze].[crm_refunds]
SELECT DISTINCT LEN(order_id) FROM [bronze].[crm_refunds]

--Check for extra type of data
SELECT DISTINCT refund_reason FROM [bronze].[crm_refunds]
SELECT DISTINCT refund_type FROM [bronze].[crm_refunds]
SELECT DISTINCT refund_method FROM [bronze].[crm_refunds]
SELECT DISTINCT refund_status FROM [bronze].[crm_refunds]

SELECT * FROM
(
SELECT *,COUNT(*) OVER (PARTITION BY refund_id) flag
FROM [bronze].[crm_refunds]
)t
WHERE flag > 1 AND (refund_method IS NULL or refund_amount IS NULL) -- identical duplicate

--Check negative value
SELECT * FROM [bronze].[crm_refunds]
WHERE refund_amount < 0


-- ============================================================

SELECT * FROM [bronze].[erp_delivery_partners]

-- Check for duplicates
SELECT COUNT(*) FROM [bronze].[erp_delivery_partners]
GROUP BY delivery_partner_id
HAVING COUNT(*) > 1

--Check for extra spaces
SELECT DISTINCT LEN(delivery_partner_id) FROM [bronze].[erp_delivery_partners]
SELECT DISTINCT LEN(phone) FROM [bronze].[erp_delivery_partners]

SELECT DISTINCT LEN(join_date) FROM [bronze].[erp_delivery_partners]
SELECT * FROM [bronze].[erp_delivery_partners]
WHERE LEN(join_date) IN (11,13)

SELECT DISTINCT LEN(avg_rating) FROM [bronze].[erp_delivery_partners]

--Check for extra type of data
SELECT DISTINCT partner_type FROM [bronze].[erp_delivery_partners]
SELECT DISTINCT vehicle_type FROM [bronze].[erp_delivery_partners]
SELECT DISTINCT avg_rating FROM [bronze].[erp_delivery_partners]
SELECT DISTINCT is_active FROM [bronze].[erp_delivery_partners]

SELECT * FROM
(
SELECT 
    join_date AS original_date,
    TRY_PARSE(TRIM(REPLACE(join_date, '!', '')) AS DATE USING 'en-US') AS clean_date
FROM [bronze].[erp_delivery_partners]
)t
WHERE LEN(clean_date) IN (11,13)

SELECT 
    join_date AS original_date,
    COALESCE(
        TRY_PARSE(TRIM(REPLACE(join_date, '!', '')) AS DATE USING 'en-US'),
        TRY_PARSE(TRIM(REPLACE(join_date, '!', '')) AS DATE USING 'en-GB')
    ) AS clean_date
FROM [bronze].[erp_delivery_partners];

-- ============================================================

SELECT * FROM [bronze].[erp_employees]

-- Check for duplicates
SELECT COUNT(*) FROM [bronze].[erp_employees]
GROUP BY emp_id
HAVING COUNT(*) > 1

--Check for extra spaces
SELECT DISTINCT LEN(emp_id) FROM [bronze].[erp_employees]
SELECT DISTINCT LEN(restaurant_id) FROM [bronze].[erp_employees]

--Check for extra type of data
SELECT DISTINCT role FROM [bronze].[erp_employees]


--Check negative or null value
SELECT * FROM [bronze].[erp_employees]
WHERE salary < 0 OR salary IS NULL

--Adjust null value and strange value 
SELECT 
    role,
    MAX(salary) AS max_value, --adjust $99999 salary with this value
    AVG(salary) AS avg_value --adjust role/salary with this value
FROM silver.erp_employees
WHERE salary <> 99999 
GROUP BY role;

-- ============================================================

SELECT * FROM [bronze].[erp_kitchen_logs]

-- Check for duplicates
SELECT COUNT(*) FROM [bronze].[erp_kitchen_logs]
GROUP BY kitchen_log_id
HAVING COUNT(*) > 1

--Check for extra spaces
SELECT DISTINCT LEN(kitchen_log_id) FROM [bronze].[erp_kitchen_logs]
SELECT DISTINCT LEN(order_item_id) FROM [bronze].[erp_kitchen_logs]
SELECT DISTINCT LEN(chef_id) FROM [bronze].[erp_kitchen_logs]
SELECT DISTINCT LEN(started_at) FROM [bronze].[erp_kitchen_logs]
SELECT DISTINCT LEN(completed_at) FROM [bronze].[erp_kitchen_logs]

SELECT chef_id FROM [bronze].[erp_kitchen_logs]
WHERE LEN(chef_id) = 9 OR chef_id IS NULL

--Check for extra type of data
SELECT DISTINCT status FROM [bronze].[erp_kitchen_logs]

-- ============================================================

SELECT * FROM [bronze].[erp_menu_items]

-- Check for duplicates
SELECT COUNT(*) FROM [bronze].[erp_menu_items]
GROUP BY item_id
HAVING COUNT(*) > 1

--Check for extra spaces
SELECT DISTINCT LEN(item_id) FROM [bronze].[erp_menu_items]

--Check for extra type of data
SELECT DISTINCT item_name FROM [bronze].[erp_menu_items]
SELECT DISTINCT category FROM [bronze].[erp_menu_items]
SELECT DISTINCT cuisine FROM [bronze].[erp_menu_items]
SELECT DISTINCT is_veg FROM [bronze].[erp_menu_items]

--Check negative value
SELECT * FROM [bronze].[erp_menu_items]
WHERE selling_price  < 0

-- ============================================================

SELECT * FROM [bronze].[erp_restaurants]

-- Check for duplicates
SELECT COUNT(*) FROM [bronze].[erp_restaurants]
GROUP BY restaurant_id
HAVING COUNT(*) > 1

--Check for extra spaces
SELECT DISTINCT LEN(restaurant_id) FROM [bronze].[erp_restaurants]
SELECT DISTINCT LEN(open_date) FROM [bronze].[erp_restaurants]
SELECT DISTINCT LEN(closed_date) FROM [bronze].[erp_restaurants]

--Check for extra type of data
SELECT DISTINCT city FROM [bronze].[erp_restaurants]
SELECT DISTINCT restaurant_type FROM [bronze].[erp_restaurants]

