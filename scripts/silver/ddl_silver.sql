USE DataWarehouse_Food

-- ============================================================================
-- CRM TABLES
-- ============================================================================

DROP TABLE IF EXISTS silver.crm_customer_reviews;
CREATE TABLE silver.crm_customer_reviews (
    review_id NVARCHAR(50),
    order_id NVARCHAR(50),
    rating INT,
    food_rating INT,
    delivery_rating INT,
    review_text NVARCHAR(MAX),
    created_at DATETIME2(0),
    dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);

DROP TABLE IF EXISTS silver.crm_customers;
CREATE TABLE silver.crm_customers (
    customer_id NVARCHAR(50),
    customer_name NVARCHAR(50),
    city NVARCHAR(50),
    phone NVARCHAR(50),
    age_group NVARCHAR(50),
    birthdate DATE,
    gender NVARCHAR(50),
    created_at DATETIME2(0),
    tier NVARCHAR(50),
    dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);

DROP TABLE IF EXISTS silver.crm_delivery_logs;
CREATE TABLE silver.crm_delivery_logs (
    delivery_id NVARCHAR(50),
    order_id NVARCHAR(50),
    delivery_partner_id NVARCHAR(50),
    assigned_at DATETIME2(0),
    picked_at DATETIME2(0),
    delivered_at DATETIME2(0),
    distance_km FLOAT,
    dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);

DROP TABLE IF EXISTS silver.crm_order_items;
CREATE TABLE silver.crm_order_items (
    order_item_id NVARCHAR(50),
    order_id NVARCHAR(50),
    item_id NVARCHAR(50),
    quantity INT,
    unit_price FLOAT,
    line_total FLOAT,
    dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);

DROP TABLE IF EXISTS silver.crm_orders;
CREATE TABLE silver.crm_orders (
    order_id NVARCHAR(50),
    customer_id NVARCHAR(50),
    restaurant_id NVARCHAR(50),
    order_datetime DATETIME2(0),
    payment_mode NVARCHAR(50),
    order_status NVARCHAR(50),
    cancel_stage NVARCHAR(50),
    cancel_reason NVARCHAR(50),
    delivery_partner_id NVARCHAR(50),
    promo_id NVARCHAR(50),
    discount_amount FLOAT,
    delivery_fee FLOAT,
    dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);

DROP TABLE IF EXISTS silver.crm_promotions;
CREATE TABLE silver.crm_promotions (
    promo_id NVARCHAR(50),
    promo_name NVARCHAR(50),
    discount_type NVARCHAR(50),
    discount_value FLOAT,
    min_order_value INT,
    valid_from NVARCHAR(50),
    valid_to DATE,
    is_active VARCHAR(50),
    dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);

DROP TABLE IF EXISTS silver.crm_refunds;
CREATE TABLE silver.crm_refunds (
    refund_id NVARCHAR(50),
    order_id NVARCHAR(50),
    refund_reason NVARCHAR(50),
    refund_type NVARCHAR(50),
    refund_amount FLOAT,
    refund_method NVARCHAR(50),
    refund_status NVARCHAR(50),
    initiated_at DATETIME2(0),
    processed_at DATETIME2(0),
    dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);

-- ============================================================================
-- ERP TABLES
-- ============================================================================

DROP TABLE IF EXISTS silver.erp_delivery_partners;
CREATE TABLE silver.erp_delivery_partners (
    delivery_partner_id NVARCHAR(50),
    name NVARCHAR(50),
    partner_type NVARCHAR(50),
    vehicle_type NVARCHAR(50),
    phone NVARCHAR(50),
    join_date DATE,
    avg_rating FLOAT,
    is_active VARCHAR(50),
    dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);

DROP TABLE IF EXISTS silver.erp_employees;
CREATE TABLE silver.erp_employees (
    emp_id NVARCHAR(50),
    name NVARCHAR(50),
    restaurant_id NVARCHAR(50),
    role NVARCHAR(50),
    hire_date DATETIME2(0),
    salary FLOAT,
    dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);

DROP TABLE IF EXISTS silver.erp_kitchen_logs;
CREATE TABLE silver.erp_kitchen_logs (
    kitchen_log_id NVARCHAR(50),
    order_item_id NVARCHAR(50),
    chef_id NVARCHAR(50),
    started_at DATETIME2(0),
    completed_at DATETIME2(0),
    status NVARCHAR(50),
    dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);

DROP TABLE IF EXISTS silver.erp_menu_items;
CREATE TABLE silver.erp_menu_items (
    item_id NVARCHAR(50),
    item_name NVARCHAR(50),
    category NVARCHAR(50),
    cuisine NVARCHAR(50),
    is_veg VARCHAR(50),
    is_available VARCHAR(50),
    selling_price FLOAT,
    dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);

DROP TABLE IF EXISTS silver.erp_restaurants;
CREATE TABLE silver.erp_restaurants (
    restaurant_id NVARCHAR(50),
    restaurant_name NVARCHAR(50),
    city NVARCHAR(50),
    restaurant_type NVARCHAR(50),
    open_date DATETIME2(0),
    is_active VARCHAR(50),
    closed_date DATE,
    dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);