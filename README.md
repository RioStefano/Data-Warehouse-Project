# Food Delivery Data Warehouse

A data warehouse project built with Microsoft SQL Server using Medallion Architecture (Bronze, Silver, Gold). I took raw data from two source systems of a food delivery business, loaded it as it is, then cleaned and standardized it with T-SQL stored procedures.

## About the data

The data comes from Kaggle and is split into two source systems:

- **ERP** ([Food Delivery ERP Raw Dataset](https://www.kaggle.com/datasets/nishantsinghpro/restaurant-erp-raw-dataset)): employees, restaurants, menu items, delivery partners, and kitchen logs (5 tables).
- **CRM** ([Food Delivery CRM Raw Dataset](https://www.kaggle.com/datasets/nishantsinghpro/restaurant-crm-raw-dataset)): customers, orders, order items, customer reviews, promotions, refunds, and delivery logs (7 tables).

The tables are logically connected with IDs (for example `order_id`, `customer_id`, `restaurant_id`), and the data is raw, so it has duplicates, strange values, and inconsistent formats.

## Architecture

```
CSV files  ->  Bronze  ->  Silver  ->  Gold
(ERP, CRM)     raw         cleaned     analysis-ready
                                       (in progress)
```

All layers live in one database, `DataWarehouse_Food`, separated by schema (`bronze`, `silver`, `gold`).

## How I did it

### 1. Bronze layer (raw data)

I created 12 tables, one for each CSV file, then wrote a stored procedure `bronze.load_bronze` to load them. It truncates each table, then loads the CSV with `BULK INSERT`. It also prints the load duration per table and uses `TRY...CATCH` to show errors.

After loading, I wrote a set of check queries (`bronze_check.sql`) to profile every table before cleaning:

- duplicate IDs
- null values
- extra spaces (using `LEN`)
- unusual values and typos (using `DISTINCT`)
- negative values and special characters

### 2. Silver layer (cleaned data)

Based on the checks, I wrote the stored procedure `silver.load_silver`, which loads clean data from bronze into silver. Main things I did:

- **Removed duplicates** with `ROW_NUMBER()`, keeping one row per ID.
- **Removed stray characters** (`@`, `#`, `!`) from text columns like names, phone, gender, and status.
- **Standardized text**: proper-case names and consistent labels (for example `upi` to `UPI`, `in_house` to `In House`).
- **Fixed mixed date formats** in delivery partner join dates using `TRY_PARSE` with US and UK formats. Text `N/A` in `closed_date` became `NULL`.
- **Handled out-of-range values**: ratings capped at 5, negative delivery fees and discount values set to 0, and unrealistic minimum order values replaced.
- **Handled missing and placeholder values**: empty labels became `N/A`, 1/0 flags became `Yes`/`No`, and employee role and salary were filled in based on salary ranges and role averages.
- Added a `dwh_create_date` column to every silver table.

### 3. Gold layer (analysis-ready data)

In progress. The next step is to model the clean silver tables into tables ready for analysis and reporting. [Update this when done, e.g. star schema with fact and dimension tables]

## Repository structure

```
.
├── datasets/
│   ├── source_crm/        # raw CRM CSV files
│   └── source_erp/        # raw ERP CSV files
├── scripts/
│   ├── ddl_bronze.sql     # create bronze tables
│   ├── load_bronze.sql    # stored procedure: CSV -> bronze
│   ├── bronze_check.sql   # data profiling queries
│   ├── ddl_silver.sql     # create silver tables
│   ├── load_silver.sql    # stored procedure: bronze -> silver
│   └── ddl_gold.sql       # create gold layer (silver -> gold)
├── LICENSE
└── README.md
```

## How to run

1. Create the database `DataWarehouse_Food` and the schemas `bronze`, `silver`, and `gold` in SQL Server.
2. Run `ddl_bronze.sql` and `ddl_silver.sql` to create the tables.
3. In `load_bronze.sql`, change the CSV file paths to match where you saved the `datasets` folder.
4. Run the stored procedures to load the bronze and silver layers:

```sql
EXEC bronze.load_bronze;
EXEC silver.load_silver;
```

5. Run `ddl_gold.sql` to create the gold layer from the clean silver tables.

## Tools

Microsoft SQL Server (SSMS), T-SQL (stored procedures, window functions, `BULK INSERT`), Git/GitHub

## Data source

Both datasets are from Kaggle and are used for learning purposes.
