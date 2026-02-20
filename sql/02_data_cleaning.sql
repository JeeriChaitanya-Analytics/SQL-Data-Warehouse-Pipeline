-- =====================================================
-- FILE: 02_data_cleaning.sql
-- LAYER: STAGING (RAW → CLEANED)
-- =====================================================

USE DATABASE SQL_DATA_CLEANING_DB;
USE SCHEMA STAGING_LAYER;
USE WAREHOUSE SQL_WH;

CREATE OR REPLACE TABLE cleaned_data AS
SELECT
    order_id,
    COALESCE(
        TRY_TO_DATE(order_date, 'YYYY-MM-DD'),
        TRY_TO_DATE(order_date, 'DD-MM-YYYY'),
        TRY_TO_DATE(order_date, 'YYYY/MM/DD')
    ) AS order_date,
    COALESCE(NULLIF(TRIM(customer_id), ''), 'Unknown') AS customer_id,
    COALESCE(NULLIF(TRIM(customer_name), ''), 'Unknown') AS customer_name,
    INITCAP(TRIM(region)) AS region,
    TRIM(product) AS product,
    TRIM(category) AS category,
    ABS(quantity) AS quantity,
    COALESCE(price, 0) AS price,
    TRY_TO_NUMBER(NULLIF(TRIM(discount), '')) AS discount,
    ABS(quantity) *
    COALESCE(price, 0) *
    (1 - COALESCE(TRY_TO_NUMBER(NULLIF(TRIM(discount), '')), 0)) AS total_amount

FROM raw_layer.raw_data;
