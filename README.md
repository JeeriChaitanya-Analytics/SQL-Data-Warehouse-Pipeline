# End-to-End SQL Data Cleaning & Star Schema Project (Snowflake)

## Project Objective

Design and implement a production-style data pipeline to clean, transform, and model messy retail sales data using SQL and Snowflake.

This project follows a layered architecture:
Raw Layer → Staging Layer → Analytics Layer (Star Schema)

---

## Tools & Technologies

* SQL (Snowflake)
* Snowflake Data Warehouse
* GitHub (Version Control)
* Excel (Raw Dataset)

---

## Data Architecture (Enterprise Design)

### Raw Layer

* Stores original messy dataset (untouched)
* Table: `raw_layer.raw_data`

### Staging Layer

* Data cleaning and transformation
* Null handling
* Standardization
* Deduplication
* Tables:

  * `cleaned_data`
  * `cleaned_deduplicated`

### Analytics Layer

* Star Schema Modeling
* Surrogate Keys
* Dimension & Fact Tables
* Tables:

  * `dim_customer`
  * `dim_product`
  * `dim_region`
  * `fact_sales_transaction`

---

## Data Profiling Insights

* Multiple date formats detected
* NULL values in customer_id & customer_name
* Invalid text values in discount column
* Negative quantities present
* Inconsistent total_amount values

Stakeholder-aligned approach used: No raw rows deleted to preserve auditability.

---

## Data Cleaning Steps Performed

* Standardized multiple date formats using TRY_TO_DATE()
* Replaced NULL/blank customer fields with 'Unknown'
* Standardized region names using INITCAP()
* Cleaned discount using TRY_TO_NUMBER()
* Fixed negative quantities using ABS()
* Recalculated total_amount using business logic
* Removed duplicates using ROW_NUMBER()

---

## Data Modeling (Star Schema)

Fact Table Grain: One row per order_id per product (transaction level)

### Dimension Tables:

* dim_customer (SCD-ready with surrogate key)
* dim_product
* dim_region

### Fact Table:

* fact_sales_transaction (linked via surrogate keys)

---

## Project Structure

sql/

* 01_data_profiling.sql
* 02_data_cleaning.sql
* 03_deduplication.sql
* 04_star_schema.sql

data/

* messy_retail_data_3000_rows.xlsx
* raw_data.csv

---

## Key Learnings

* End-to-end data pipeline design in Snowflake
* Data profiling & stakeholder-driven cleaning
* Handling NULLs and messy real-world data
* Deduplication using window functions
* Star schema modeling with surrogate keys
* Enterprise data warehouse architecture

---

## 🚀 Future Enhancements

* Implement SCD Type 2 for dim_customer
* Build Power BI dashboard on fact table
* Automate pipeline using Snowflake Tasks
