# 🏗️ Data Warehouse Project Data Catalog [![Oracle](https://img.shields.io/badge/Oracle-F80000?style=flat&logo=Oracle&logoColor=white)](https://www.oracle.com/database/)

This data catalog documents all tables, columns, data types, and descriptions used in the SQL project.

---

## 1. `gold.dim_customers` [Dimension Table]

- <b>Purpose</b>: Store customer details enrchied with demographic and geographic data.

| Column Name     | Data Type | Description                                                                |
| --------------- | --------- | -------------------------------------------------------------------------- |
| customer_key    | NUMBER    | Surrogate key uniquely identifying each customer record in the table       |
| customer_id     | NUMBER    | Unique numerical identifier assigned to each customer                      |
| customer_number | VARCHAR2  | Alphanumeric identifier representing the customer                          |
| first_name      | VARCHAR2  | Customer's first name as recorded in the system                            |
| last_name       | VARCHAR2  | Customer's last name as recorded in the system                             |
| country         | VARCHAR2  | Country of residence of the customer                                       |
| marital_status  | VARCHAR2  | Marital status of the customer                                             |
| gender          | VARCHAR2  | Gender of the customer                                                     |
| birth_date      | DATE      | Date of birth of the customer, formatted as DD-MM-RR                       |
| create_date     | DATE      | Date when customer record was created in the system, formatted as DD-MM-RR |

---

## 2. `gold.dim_products` [Dimension Table]

- <b>Purpose</b>: Prodcut information about the products and their attributes.

| Column Name    | Data Type | Description                                                     |
| -------------- | --------- | --------------------------------------------------------------- |
| product_key    | NUMBER    | Surrogate key uniquely identifying each product record          |
| product_id     | NUMBER    | Unique numerical identifier assigned to each product            |
| product_number | VARCHAR2  | Alphanumeric identifier representing the product                |
| product_name   | VARCHAR2  | Descriptive name of the product                                 |
| category_id    | VARCHAR2  | Unique identifier for the product's category                    |
| category       | VARCHAR2  | Category to which the product belongs                           |
| subcategory    | VARCHAR2  | More detailed classification of the product within the category |
| maintenance    | VARCHAR2  | Indicates whether the product requires maintenance              |
| cost           | NUMBER    | Cost or base price of the product, measured in monetary units   |
| product_line   | VARCHAR2  | Specific product line or series to which product belongs        |
| start_date     | DATE      | Date at which the product became available for sale or use      |

---

## 3. `gold.fact_sales` [Fact Table]

- <b>Purpose</b>: Store transactional sales data for analytical purpose.

| Column Name   | Data Type | Description                                                     |
| ------------- | --------- | --------------------------------------------------------------- |
| order_number  | VARCHAR2  | Unique alphanumeric identifier for each sales order             |
| product_key   | VARCHAR2  | Surrogate key linking the order to the product dimension table  |
| customer_key  | VARCHAR2  | Surrogate key linking the order to the customer dimension table |
| order_date    | DATE      | Date at which order was placed                                  |
| shipping_date | DATE      | Date at which order was shipped                                 |
| due_date      | DATE      | Date at which order payment was due                             |
| sales_amount  | NUMBER    | Total monetary value of the sales for the line item             |
| quantity      | NUMBER    | Number of units of the product ordered for the line item        |
| price         | NUMBER    | Price per unit of the product for the line item                 |
