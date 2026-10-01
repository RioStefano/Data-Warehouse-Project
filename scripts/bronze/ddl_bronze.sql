DROP TABLE IF EXISTS bronze.crm_customer_reviews;
CREATE TABLE bronze.crm_customer_reviews (
	review_id NVARCHAR(50),
	order_id NVARCHAR(50),
	rating INT,
	food_rating INT,
	delivery_rating INT,
	review_text NVARCHAR(MAX),
	created_at DATETIME
);

DROP TABLE IF EXISTS bronze.crm_customers;
CREATE TABLE bronze.crm_customers (
	customer_id NVARCHAR(50),
	customer_name NVARCHAR(50),
	city NVARCHAR(50),
	phone NVARCHAR(50),
	age_group NVARCHAR(50),
	birthdate DATETIME,
	gender NVARCHAR(50),
	created_at DATETIME,
	tier NVARCHAR(50)
);

DROP TABLE IF EXISTS bronze.crm_delivery_logs;
CREATE TABLE bronze.crm_delivery_logs (
	delivery_id NVARCHAR(50),
	order_id NVARCHAR(50),
	delivery_partner_id NVARCHAR(50),
	assigned_at DATETIME,
	picked_at DATETIME,
	delivered_at DATETIME,
	distance_km FLOAT
);

DROP TABLE IF EXISTS bronze.crm_order_items;
CREATE TABLE bronze.crm_order_items (
	order_item_id NVARCHAR(50),
	order_id NVARCHAR(50),
	item_id NVARCHAR(50),
	quantity INT,
	unit_price FLOAT,
	line_total FLOAT
);

DROP TABLE IF EXISTS bronze.crm_orders;
CREATE TABLE bronze.crm_orders (
	order_id NVARCHAR(50),
	customer_id NVARCHAR(50),
	restaurant_id NVARCHAR(50),
	order_datetime DATETIME,
	payment_mode NVARCHAR(50),
	order_status NVARCHAR(50),
	cancel_stage NVARCHAR(50),
	cancel_reason NVARCHAR(50),
	delivery_partner_id NVARCHAR(50),
	promo_id NVARCHAR(50),
	discount_amount FLOAT,
	delivery_fee FLOAT
);

DROP TABLE IF EXISTS bronze.crm_promotions;
CREATE TABLE bronze.crm_promotions (
	promo_id NVARCHAR(50),
	promo_name NVARCHAR(50),
	discount_type NVARCHAR(50),
	discount_value FLOAT,
	min_order_value INT,
	valid_from NVARCHAR(50),
	valid_to DATE,
	is_active INT
);

DROP TABLE IF EXISTS bronze.crm_refunds;
CREATE TABLE bronze.crm_refunds (
	refund_id NVARCHAR(50),
	order_id NVARCHAR(50),
	refund_reason NVARCHAR(50),
	refund_type NVARCHAR(50),
	refund_amount FLOAT,
	refund_method NVARCHAR(50),
	refund_status NVARCHAR(50),
	initiated_at DATETIME,
	processed_at DATETIME
);

DROP TABLE IF EXISTS bronze.erp_delivery_partners;
CREATE TABLE bronze.erp_delivery_partners (
	delivery_partner_id NVARCHAR(50),
	name NVARCHAR(50),
	partner_type NVARCHAR(50),
	vehicle_type NVARCHAR(50),
	phone NVARCHAR(50),
	join_date NVARCHAR(50),
	avg_rating FLOAT,
	is_active INT
);

DROP TABLE IF EXISTS bronze.erp_employees;
CREATE TABLE bronze.erp_employees (
	emp_id NVARCHAR(50),
	name NVARCHAR(50),
	restaurant_id NVARCHAR(50),
	role NVARCHAR(50),
	hire_date DATETIME,
	salary FLOAT
);

DROP TABLE IF EXISTS bronze.erp_kitchen_logs;
CREATE TABLE bronze.erp_kitchen_logs (
	kitchen_log_id NVARCHAR(50),
	order_item_id NVARCHAR(50),
	chef_id NVARCHAR(50),
	started_at DATETIME,
	completed_at DATETIME,
	status NVARCHAR(50)
);

DROP TABLE IF EXISTS bronze.erp_menu_items;
CREATE TABLE bronze.erp_menu_items (
	item_id NVARCHAR(50),
	item_name NVARCHAR(50),
	category NVARCHAR(50),
	cuisine NVARCHAR(50),
	is_veg FLOAT,
	is_available INT,
	selling_price FLOAT
);

DROP TABLE IF EXISTS bronze.erp_restaurants;
CREATE TABLE bronze.erp_restaurants (
	restaurant_id NVARCHAR(50),
	restaurant_name NVARCHAR(50),
	city NVARCHAR(50),
	restaurant_type NVARCHAR(50),
	open_date DATETIME,
	is_active INT,
	closed_date NVARCHAR(50)
);