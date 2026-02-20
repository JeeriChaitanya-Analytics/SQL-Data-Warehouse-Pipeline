-- =====================================================
-- FILE: 01_data_profiling.sql
-- LAYER: RAW LAYER (DATA PROFILING)
-- PROJECT: SQL DATA CLEANING PIPELINE
-- AUTHOR: Jeeri Chaitanya
-- =====================================================

USE DATABASE SQL_DATA_CLEANING_DB;
USE SCHEMA RAW_LAYER;
USE WAREHOUSE SQL_WH;

-- 1. Total Records
SELECT COUNT(*) AS total_records
FROM raw_data;

-- 2. Check NULL Values Column-wise
SELECT
    COUNT_IF(order_id IS NULL) AS null_order_id,
    COUNT_IF(order_date IS NULL) AS null_order_date,
    COUNT_IF(customer_id IS NULL) AS null_customer_id,
    COUNT_IF(customer_name IS NULL) AS null_customer_name,
    COUNT_IF(discount IS NULL) AS null_discount
FROM raw_data;

-- 3. Detect Invalid Date Formats
SELECT order_date
FROM raw_data
WHERE TRY_TO_DATE(order_date) IS NULL
  AND order_date IS NOT NULL;

-- 4. Check Negative Quantities
SELECT *
FROM raw_data
WHERE quantity < 0;

-- 5. Check Non-Numeric Discount Values
SELECT discount
FROM raw_data
WHERE TRY_TO_NUMBER(discount) IS NULL
  AND discount IS NOT NULL;
