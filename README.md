# 🏗️ Data Warehouse Project [![Oracle](https://img.shields.io/badge/Oracle-F80000?style=flat&logo=Oracle&logoColor=white)](https://www.oracle.com/database/)

This repository contains an industry-oriented Data Warehouse project designed to practice Oracle SQL, schema design, and ETL concepts using the Medallion Architecture (Bronze, Silver, Gold layers).

Each layer includes:

- SQL Scripts (DDL, DML, and transformations)
- Sample Datasets (CSV files for ingestion)
- ERD Diagrams (schema and relationships)
- Layer-specific README with details and queries

## 🗃️ ER Diagrams

`Raw Relations` :- There is a need of transforming certain values to connect the tables.

![image.png](./DW_Project_1.png)

## 📂 Project Structure

##### 🟤 Bronze Layer (Raw Data Ingestion)

- Stores raw, unprocessed data from CRM and ERP systems.
- Data is ingested directly as received (may include duplicates, nulls, inconsistent formats).

##### ⚪ Silver Layer (Cleansed / Standardized Data)

- Contains cleaned, de-duplicated, and standardized data.
- Business rules applied: data quality checks, format standardization, referential integrity.

##### 🟡 Gold Layer (Business-Ready Data)

- Contains aggregated and business-ready tables for analytics and reporting.
- Modeled using fact/dimension schema for BI consumption.

## 📁 Example Use Cases

- CRM Analysis → Active customers, lead conversion rates.
- ERP Analysis → Supplier performance, order trends.
- Cross-Domain → Customer purchase behavior across CRM & ERP.

## 📄 Dataset Disclaimer

- All datasets used are synthetic and created for educational purposes.
- No real CRM/ERP data is used.
- Any resemblance to actual entities is purely coincidental.

## 🪪 License

This project is licensed under the MIT License.

## 🫂 Acknowledgments

Special thanks to [Baraa Al Khatib](https://www.linkedin.com/in/baraa-khatib-salkini) for the [YouTube tutorial](https://www.youtube.com/watch?v=VIDEO_ID) that guided me through this project.
