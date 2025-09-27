-- Go Table by Table and within the table, column by column

-- Table:- bronze.cust_info
-- checking for primary key constraint
SELECT cst_id, COUNT(*) FROM bronze.cust_info GROUP BY cst_id HAVING COUNT(*) > 1;
SELECT cst_id, COUNT(*) FROM silver.cust_info GROUP BY cst_id HAVING COUNT(*) > 1;

-- Checking the string values for any trimming
SELECT cst_firstname FROM bronze.cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname FROM bronze.cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_marital_status FROM bronze.cust_info
WHERE cst_marital_status!= TRIM(cst_marital_status);

SELECT cst_gndr FROM bronze.cust_info
WHERE cst_gndr!= TRIM(cst_gndr);

-- bronze.cust_info => processed data(silver.cust_info)
CREATE TABLE silver.cust_info AS
SELECT
    cst_id, cst_key, 
    TRIM(cst_firstname) AS cst_firstname, TRIM(cst_lastname) AS cst_lastname, 
    CASE UPPER(TRIM(cst_marital_status))
        WHEN 'S' THEN 'Single'
        WHEN 'M' THEN 'Married'
        ELSE 'N/A'
    END AS cst_marital_status, 
    CASE UPPER(TRIM(cst_gndr))
        WHEN 'M' THEN 'Male'
        WHEN 'F' THEN 'Female'
        ELSE 'N/A'
    END AS cst_gndr, 
    cst_create_date
FROM (
    SELECT 
        cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date,
        ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
    FROM bronze.cust_info
    )t
WHERE t.flag_last = 1;

-- Custom columns for better analysis
ALTER TABLE silver.cust_info ADD (dwh_create_date DATE DEFAULT CURRENT_DATE);
ALTER TABLE silver.cust_info ADD (dwh_update_date DATE DEFAULT CURRENT_DATE);

SELECT * FROM silver.cust_info;

-- =============================================================================


-- Table:- bronze.prd_info
-- checking for primary key constraint
SELECT prd_id, COUNT(*) FROM bronze.prd_info GROUP BY prd_id HAVING COUNT(*) > 1;
SELECT prd_id, COUNT(*) FROM silver.prd_info GROUP BY prd_id HAVING COUNT(*) > 1;

-- checking unwanted spaces in prd_nm
SELECT
    prd_nm
FROM bronze.prd_info
-- FROM silver.prd_info
WHERE prd_nm != TRIM(prd_nm);

-- check for nulls or negaative numbers in prd_cost
SELECT 
    prd_cost
FROM bronze.prd_info
-- FROM silver.prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;

-- prd_line
SELECT
    DISTINCT prd_line
FROM bronze.prd_info;
--FROM silver.prd_info;

-- prd_start_dt
SELECT 
    *
FROM bronze.prd_info
WHERE prd_start_dt < TO_DATE(prd_end_dt, 'DD-MM-YYYY');

-- Checking DATE format
SELECT
    prd_start_dt,
    prd_start_dt - 1,
    prd_end_dt,
    TO_DATE(prd_end_dt, 'DD-MM-YYYY') AS end_dtt,
    TO_DATE(prd_end_dt, 'DD-MM-YYYY') - 1 AS end_dt_1
FROM bronze.prd_info;

-- Fixing overlapping dates
SELECT
    prd_key,
    prd_start_dt,
--    TO_DATE(prd_end_dt, 'DD-MM-YYYY') AS prd_end_dt,
    TO_DATE(prd_end_dt, 'DD-MM-YYYY') AS prd_end_dt,
    LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS prd_end_dt_lead
FROM bronze.prd_info
WHERE prd_key IN ('AC-HE-HL-U509-R', 'AC-HE-HL-U509');

-- prd_start_dt => DD-MM-YYYY
-- prd_end_dt => DD-MM-YYYY

-- bronze.prd_info => processed data(silver.prd_info)
CREATE TABLE silver.prd_info AS
SELECT 
    prd_id, 
    REPLACE(SUBSTR(prd_key, 1,5), '-', '_') AS cat_id,
    SUBSTR(prd_key, 7,LENGTH(prd_key)) AS prd_key,
    TRIM(prd_nm) AS prd_nm, 
    COALESCE(prd_cost,0) AS prd_cost, 
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'T' THEN 'Touring'
        WHEN 'S' THEN 'Other Sales'
        ELSE 'N/A'
    END AS prd_line,
    prd_start_dt, 
    LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS prd_end_dt
FROM bronze.prd_info;

-- Custom columns for better analysis
ALTER TABLE silver.prd_info ADD (dwh_create_date DATE DEFAULT CURRENT_DATE);
ALTER TABLE silver.prd_info ADD (dwh_update_date DATE DEFAULT CURRENT_DATE);

SELECT * FROM silver.prd_info;


-- =============================================================================


-- Table:- bronze.sales_details
-- sls_ord_num
-- Whitespaces in sls_ord_num
SELECT sls_ord_num FROM bronze.sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

-- Duplicated sls_ord_num => not an issue in this case
SELECT
    sls_ord_num,
    COUNT(*)
FROM bronze.sales_details
GROUP BY sls_ord_num
HAVING COUNT(*) > 1;

SELECT * FROM bronze.sales_details
WHERE sls_ord_num = 'SO51410';

-- sls_prd_key
SELECT * FROM bronze.sales_details
WHERE sls_prd_key NOT IN (
    SELECT prd_key FROM silver.prd_info
);

-- sls_cust_id
SELECT * FROM bronze.sales_details
WHERE sls_cust_id NOT IN (
    SELECT cst_id FROM silver.cust_info
);

-- date columns in sales_details
SELECT NULLIF(sls_order_dt, 0) AS sls_order_dt
FROM bronze.sales_details
WHERE sls_order_dt <= 0;

SELECT NULLIF(sls_ship_dt, 0) AS sls_ship_dt
FROM bronze.sales_details
WHERE sls_ship_dt <= 0;

SELECT NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.sales_details
WHERE sls_due_dt <= 0;

SELECT
    NULLIF(sls_order_dt, 0) AS sls_ord_dt,
    sls_ship_dt,
    sls_due_dt
FROM bronze.sales_details
WHERE sls_order_dt <= 0 OR LENGTH(sls_order_dt) != 8;

SELECT
    sls_ord_num,
    CASE 
        WHEN sls_order_dt <= 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
        ELSE TO_DATE(TO_CHAR(sls_order_dt), 'YYYYMMDD')
    END AS sls_order_dt,
    CASE 
        WHEN sls_ship_dt <= 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
        ELSE TO_DATE(TO_CHAR(sls_ship_dt), 'YYYYMMDD')
    END AS sls_ship_dt,
    CASE 
        WHEN sls_due_dt <= 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
        ELSE TO_DATE(TO_CHAR(sls_due_dt), 'YYYYMMDD')
    END AS sls_due_dt
FROM bronze.sales_details;

-- checking ord_dt <= ship_dt <= due_dt
SELECT
    sls_ord_num,
    CASE 
        WHEN sls_order_dt <= 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
        ELSE TO_DATE(TO_CHAR(sls_order_dt), 'YYYYMMDD')
    END AS sls_order_dt,
    CASE 
        WHEN sls_ship_dt <= 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
        ELSE TO_DATE(TO_CHAR(sls_ship_dt), 'YYYYMMDD')
    END AS sls_ship_dt,
    CASE 
        WHEN sls_due_dt <= 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
        ELSE TO_DATE(TO_CHAR(sls_due_dt), 'YYYYMMDD')
    END AS sls_due_dt
FROM bronze.sales_details
WHERE sls_order_dt > sls_ship_dt;

-- checking sales, quantity & price
SELECT
    DISTINCT
    sls_sales,
    sls_quantity,
    sls_price,
    CASE
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
            THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales_correct,    
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0 OR sls_price != sls_sales / ABS(sls_price) 
            THEN ROUND(sls_sales / NULLIF(sls_quantity, 0), 2)
        ELSE sls_price
    END AS sls_price_correct
FROM bronze.sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- bronze.sales_details => processed data(silver.sales_details)
CREATE TABLE silver.sales_details AS
SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    -- Changing DATATYPE from NUMBER to DATE and also checking if they are only accepted values.   
    CASE 
        WHEN sls_order_dt <= 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
        ELSE TO_DATE(TO_CHAR(sls_order_dt), 'YYYYMMDD')
    END AS sls_order_dt,
    CASE 
        WHEN sls_ship_dt <= 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
        ELSE TO_DATE(TO_CHAR(sls_ship_dt), 'YYYYMMDD')
    END AS sls_ship_dt,
    CASE 
        WHEN sls_due_dt <= 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
        ELSE TO_DATE(TO_CHAR(sls_due_dt), 'YYYYMMDD')
    END AS sls_due_dt,
    -- Using sales, quantity and price relationship to derive correct values.
    CASE
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
            THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0
            THEN ROUND(sls_sales / NULLIF(sls_quantity, 0), 2)
        ELSE sls_price
    END AS sls_price
FROM bronze.sales_details;

-- Adding custom columns for better analysis
ALTER TABLE silver.sales_details ADD (dwh_create_date DATE DEFAULT CURRENT_DATE);
ALTER TABLE silver.sales_details ADD (dwh_update_date DATE DEFAULT CURRENT_DATE);



SELECT * FROM silver.cust_info;
SELECT * FROM silver.prd_info;
SELECT * FROM silver.sales_details;


