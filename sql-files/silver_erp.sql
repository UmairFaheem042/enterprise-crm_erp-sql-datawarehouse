SELECT * FROM bronze.cust_az12;












-- =============================================================================


ALTER TABLE silver.cust_az12 ADD (dwh_create_date DATE DEFAULT CURRENT_DATE);
ALTER TABLE silver.cust_az12 ADD (dwh_update_date DATE DEFAULT CURRENT_DATE);

ALTER TABLE silver.loc_a101 ADD (dwh_create_date DATE DEFAULT CURRENT_DATE);
ALTER TABLE silver.loc_a101 ADD (dwh_update_date DATE DEFAULT CURRENT_DATE);

ALTER TABLE silver.PX_CAT_G1V2 ADD (dwh_create_date DATE DEFAULT CURRENT_DATE);
ALTER TABLE silver.PX_CAT_G1V2 ADD (dwh_update_date DATE DEFAULT CURRENT_DATE);