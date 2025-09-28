-- BRONE Tablespace
CREATE TABLESPACE bronze DATAFILE 'bronze_data01.dbf' SIZE 200M AUTOEXTEND ON;

-- SILVER Tablespace
CREATE TABLESPACE silver DATAFILE 'silver_data01.dbf' SIZE 200M AUTOEXTEND ON;

-- GOLD Tablespace
CREATE TABLESPACE gold DATAFILE 'gold_data01.dbf' SIZE 200M AUTOEXTEND ON;

-- Getting all Tablespaces
SELECT file_name
FROM dba_data_files;

-- Creating Users  
CREATE USER bronze IDENTIFIED BY 12345
  DEFAULT TABLESPACE bronze
  QUOTA UNLIMITED ON bronze;

CREATE USER silver IDENTIFIED BY 12345
  DEFAULT TABLESPACE silver
  QUOTA UNLIMITED ON silver;
  
CREATE USER gold IDENTIFIED BY 12345
  DEFAULT TABLESPACE gold
  QUOTA UNLIMITED ON gold;


-- Common role for app users
CREATE ROLE app_role;

-- Assign normal privileges
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE TO app_role;

-- Grant role to users
GRANT app_role TO bronze;
GRANT app_role TO silver;
GRANT app_role TO gold;


-- Getting all users
SELECT * FROM all_users
WHERE username = 'BRONZE';
