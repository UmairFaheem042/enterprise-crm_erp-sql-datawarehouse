-- Table:- bronze.cust_az12
-- cid is not consistent(NASAW... & AW...)
SELECT
    cid,
    SUBSTR(cid, 4, LENGTH(cid)),
    bdate,
    gen
FROM bronze.cust_az12
WHERE cid LIKE 'NAS%';
--FROM silver.cust_az12
--WHERE cid LIKE 'NAS%';

SELECT 
    CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTR(cid, 4, LENGTH(cid))
        ELSE cid
    END AS cid,
    bdate,
    gen
FROM bronze.cust_az12
WHERE CASE
        WHEN cid LIKE 'NAS%' THEN SUBSTR(cid, 4, LENGTH(cid))
        ELSE cid
    END NOT IN (
    SELECT cst_key FROM silver.cust_info
);

-- Identifying out of range dates
SELECT
    TO_CHAR(bdate, 'DD-MM-YYYY') AS invalid_bdate
FROM bronze.cust_az12
--FROM silver.cust_az12
WHERE bdate > SYSDATE;


-- gender
SELECT DISTINCT 
    gen,
    CASE 
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        ELSE 'N/A'
    END AS gender
FROM bronze.cust_az12;
--FROM silver.cust_az12;


-- =============================================================================
-- Table:- bronze.loc_a101
-- cid
SELECT 
    cid,
    REPLACE(cid, '-', '') AS corrected_cid 
FROM bronze.loc_a101;

SELECT
    cid,
    REPLACE(cid, '-', '') AS corrected_cid
FROM bronze.loc_a101
WHERE REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM silver.cust_info);

-- cntry
SELECT DISTINCT cntry
FROM bronze.loc_a101;

SELECT DISTINCT 
    cntry,
    CASE
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'N/A'
        ELSE TRIM(cntry)
    END AS cntry    
FROM bronze.loc_a101;
--FROM silver.loc_a101;


-- =============================================================================
-- Table:- bronze.PX_CAT_G1V2
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM bronze.PX_CAT_G1V2;

-- id
SELECT
    id
FROM bronze.PX_CAT_G1V2
WHERE id NOT IN (SELECT cat_id FROM silver.prd_info);

-- cat
SELECT DISTINCT cat
FROM bronze.PX_CAT_G1V2;

-- subcat
SELECT DISTINCT subcat
FROM bronze.PX_CAT_G1V2;

-- cat & subcat
SELECT cat, subcat
FROM bronze.PX_CAT_G1V2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat);

-- maintenance
SELECT
    DISTINCT maintenance
FROM bronze.PX_CAT_G1V2;

SELECT
    DISTINCT maintenance
FROM bronze.PX_CAT_G1V2
WHERE maintenance != TRIM(maintenance);


-- =============================================================================
-- MAIN QUERIES / BRONZE -> SILVER
-- cust_az12
CREATE TABLE silver.cust_az12 AS
    SELECT 
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTR(cid, 4, LENGTH(cid))
            ELSE cid
        END AS cid,
        CASE
            WHEN bdate > SYSDATE THEN NULL
            ELSE bdate
        END AS bdate,
        CASE 
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            ELSE 'N/A'
        END AS gen
    FROM bronze.cust_az12;
ALTER TABLE silver.cust_az12 ADD (dwh_create_date DATE DEFAULT CURRENT_DATE);

-- loc_a101
CREATE TABLE silver.loc_a101 AS
    SELECT
        REPLACE(cid, '-', '') AS cid,
        CASE
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) = '' OR TRIM(cntry) IS NULL THEN 'N/A'
            ELSE TRIM(cntry)
        END AS cntry   
    FROM bronze.loc_a101;
ALTER TABLE silver.loc_a101 ADD (dwh_create_date DATE DEFAULT CURRENT_DATE);

-- PX_CAT_G1V2
CREATE TABLE silver.PX_CAT_G1V2 AS
    SELECT
        id, cat, subcat, maintenance
    FROM bronze.PX_CAT_G1V2;
ALTER TABLE silver.PX_CAT_G1V2 ADD (dwh_create_date DATE DEFAULT CURRENT_DATE);
    

-- =============================================================================
SELECT * FROM silver.cust_az12;
SELECT * FROM silver.loc_a101;
SELECT * FROM silver.PX_CAT_G1V2;