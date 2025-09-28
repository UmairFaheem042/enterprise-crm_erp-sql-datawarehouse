-- Complte Customer Information => Dimension
-- Checking whether after joining we get duplicates or not.
SELECT cst_id, COUNT(*) FROM (
SELECT 
    ci.cst_id, ci.cst_key, ci.cst_firstname, ci.cst_lastname, ci.cst_marital_status,
    CASE
        WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'N/A')
    END AS gender,
    ci.cst_create_date, ca.bdate, cl.cntry
FROM silver.cust_info ci
LEFT JOIN silver.cust_az12 ca ON ca.cid = ci.cst_key
LEFT JOIN silver.loc_a101 cl ON cl.cid = ci.cst_key
)t GROUP BY t.cst_id
HAVING COUNT(*) > 1;

-- Two columns for gender
-- Taking CRM as the Master for gender info
SELECT 
    DISTINCT
    ci.cst_gndr, ca.gen,
    CASE
        WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'N/A')
    END AS sd
FROM silver.cust_info ci
LEFT JOIN silver.cust_az12 ca ON ca.cid = ci.cst_key
LEFT JOIN silver.loc_a101 cl ON cl.cid = ci.cst_key;


-- =============================================================================
-- Granting privileges to gold for creating VIEW
GRANT SELECT ON silver.cust_info TO gold;
GRANT SELECT ON silver.prd_info TO gold;
GRANT SELECT ON silver.sales_details TO gold;
GRANT SELECT ON silver.cust_az12 TO gold;
GRANT SELECT ON silver.loc_a101 TO gold;
GRANT SELECT ON silver.PX_CAT_G1V2 TO gold;
GRANT CREATE ANY VIEW TO system;
-- =============================================================================

CREATE VIEW gold.dim_customers
AS 
SELECT 
    -- surrogate key for making a primary key since we don't have one
    ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    cl.cntry AS country,
    ci.cst_marital_status AS marital_status,
    -- there are 2 gender columns
    CASE
        WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'N/A')
    END AS gender,
    ca.bdate AS birth_date,
    ci.cst_create_date AS create_date
FROM silver.cust_info ci
LEFT JOIN silver.cust_az12 ca ON ca.cid = ci.cst_key
LEFT JOIN silver.loc_a101 cl ON cl.cid = ci.cst_key;


-- =============================================================================
-- Complte Product Information => Dimension
-- Checking whether after joining we get duplicates or not.
SELECT 
    prd_key, COUNT(*) 
FROM (
    SELECT 
        pn.prd_id, pn.cat_id, pn.prd_key, pn.prd_nm, pn.prd_cost, pn.prd_line, pn.prd_start_dt,
        pc.cat, pc.subcat, pc.maintenance
    FROM silver.prd_info pn
    LEFT JOIN silver.PX_CAT_G1V2 pc ON pc.id = pn.cat_id
    -- Filtering out all historical data
    WHERE pn.prd_end_dt IS NULL
)t GROUP BY prd_key HAVING COUNT(*) > 1;

-- =============================================================================
CREATE VIEW gold.dim_products
AS
SELECT 
    ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.prd_id AS product_id,  
    pn.prd_key AS product_number,  
    pn.prd_nm AS product_name, 
    pn.cat_id AS category_id,
    pc.cat AS category, 
    pc.subcat AS subcategory, 
    pc.maintenance AS maintenance,
    pn.prd_cost AS cost, 
    pn.prd_line AS product_line, 
    pn.prd_start_dt AS start_date
FROM silver.prd_info pn
LEFT JOIN silver.PX_CAT_G1V2 pc ON pc.id = pn.cat_id
-- Filtering out all historical data
WHERE pn.prd_end_dt IS NULL;


-- =============================================================================
-- Complete Sales Details Information => Fact

CREATE VIEW gold.fact_sales
AS
SELECT
    sd.sls_ord_num AS order_number,
--    sd.sls_prd_key,
    pr.product_key, -- dimension key for products
--    sd.sls_cust_id,
    cu.customer_key, -- dimension key for customers
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS shipping_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM silver.sales_details sd
LEFT JOIN gold.dim_products pr ON pr.product_number = sd.sls_prd_key
LEFT JOIN gold.dim_customers cu ON cu.customer_id = sd.sls_cust_id;


-- =============================================================================
SELECT * FROM silver.cust_info;
SELECT * FROM silver.prd_info;
SELECT * FROM silver.sales_details;

SELECT * FROM silver.cust_az12;
SELECT * FROM silver.loc_a101;
SELECT * FROM silver.PX_CAT_G1V2;