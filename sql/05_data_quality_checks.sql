-- =========================================================
-- DATA QUALITY & VALIDATION CHECKS
-- Project: End-to-End SQL Data Warehouse Pipeline
-- Layers Validated: RAW → STAGING → ANALYTICS
-- Purpose: Ensure data integrity, completeness, and consistency
-- Author: Jeeri Chaitanya
-- =========================================================

USE DATABASE SQL_DATA_CLEANING_DB;
USE WAREHOUSE SQL_WH;

-- ============================================
-- 1. RAW vs STAGING Record Count Validation
-- ============================================

SELECT 'RAW_COUNT' AS layer, COUNT(*) AS record_count
FROM raw_layer.raw_data

UNION ALL

SELECT 'STAGING_CLEANED_COUNT', COUNT(*)
FROM staging_layer.cleaned_data

UNION ALL

SELECT 'STAGING_DEDUP_COUNT', COUNT(*)
FROM staging_layer.cleaned_deduplicated;

-- ============================================
-- 2. NULL Critical Field Checks (Business Rules)
-- ============================================

SELECT
    COUNT_IF(order_id IS NULL) AS null_order_id,
    COUNT_IF(order_date IS NULL) AS null_order_date,
    COUNT_IF(customer_id IS NULL) AS null_customer_id
FROM staging_layer.cleaned_deduplicated;

-- ============================================
-- 3. Dimension Table Validation
-- ============================================

SELECT COUNT(*) AS dim_customer_count
FROM analytics_layer.dim_customer;

SELECT COUNT(*) AS dim_product_count
FROM analytics_layer.dim_product;

SELECT COUNT(*) AS dim_category_count
FROM analytics_layer.dim_category;

-- ============================================
-- 4. Fact Table Validation
-- ============================================

SELECT COUNT(*) AS fact_sales_count
FROM analytics_layer.fact_sales;

-- Check for NULL Foreign Keys (Should be ZERO due to Unknown SK = 0)
SELECT
    COUNT_IF(customer_sk IS NULL) AS null_customer_fk,
    COUNT_IF(product_sk IS NULL) AS null_product_fk,
    COUNT_IF(category_sk IS NULL) AS null_category_fk
FROM analytics_layer.fact_sales;

-- ============================================
-- 5. Revenue Consistency Check
-- ============================================

SELECT
    SUM(total_amount) AS total_revenue,
    SUM(quantity) AS total_quantity
FROM analytics_layer.fact_sales;
