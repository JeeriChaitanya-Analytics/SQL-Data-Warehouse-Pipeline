-- =====================================================
-- FILE: 03_deduplication.sql
-- LAYER: STAGING (DEDUPLICATION)
-- =====================================================

USE DATABASE SQL_DATA_CLEANING_DB;
USE SCHEMA STAGING_LAYER;
USE WAREHOUSE SQL_WH;

-- Check Duplicate Business Keys (order_id)
SELECT order_id, COUNT(*) AS duplicate_count
FROM cleaned_data
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Create Deduplicated Table (Enterprise Logic)
CREATE OR REPLACE TABLE cleaned_deduplicated AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY order_id
               ORDER BY 
                   CASE WHEN order_date IS NULL THEN 1 ELSE 0 END,
                   order_date DESC
           ) AS rn
    FROM cleaned_data
)
WHERE rn = 1;

-- Final Validation Check
SELECT COUNT(*) FROM cleaned_data;
SELECT COUNT(*) FROM cleaned_deduplicated;
