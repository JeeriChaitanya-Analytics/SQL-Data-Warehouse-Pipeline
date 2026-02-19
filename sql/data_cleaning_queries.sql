-- =========================================
-- PROJECT: SQL DATA CLEANING PIPELINE
-- LAYERS: RAW → STAGING → ANALYTICS
-- AUTHOR: Jeeri Chaitanya
-- =========================================

USE DATABASE SQL_DATA_CLEANING_DB;
USE WAREHOUSE SQL_WH;

STEP 1 — DATA PROFILING (From RAW Layer)

1.1 Total Records
SELECT COUNT(*) AS total_records
FROM raw_layer.raw_data;

1.2 Check NULL Values Column-wise
SELECT
    COUNT_IF(order_id IS NULL) AS null_order_id,
    COUNT_IF(order_date IS NULL) AS null_order_date,
    COUNT_IF(customer_id IS NULL) AS null_customer_id,
    COUNT_IF(customer_name IS NULL) AS null_customer_name,
    COUNT_IF(discount IS NULL) AS null_discount
FROM raw_layer.raw_data;

1.3 Detect Invalid Date Formats
SELECT order_date
FROM raw_layer.raw_data
WHERE TRY_TO_DATE(order_date) IS NULL
  AND order_date IS NOT NULL;

1.4 Check Negative Quantities
SELECT *
FROM raw_layer.raw_data
WHERE quantity < 0;

1.5 Check Text Inside Discount (like 'abc')
SELECT discount
FROM raw_layer.raw_data
WHERE TRY_TO_NUMBER(discount) IS NULL
  AND discount IS NOT NULL;

STEP 2 — CREATE CLEANED TABLE (Staging Layer)

CREATE OR REPLACE TABLE staging_layer.cleaned_data AS
SELECT
    order_id,
    COALESCE(
        TRY_TO_DATE(order_date, 'YYYY-MM-DD'),
        TRY_TO_DATE(order_date, 'DD-MM-YYYY'),
        TRY_TO_DATE(order_date, 'YYYY/MM/DD')
    ) AS order_date,
    COALESCE(
        NULLIF(TRIM(customer_id), ''),
        'Unknown'
    ) AS customer_id,
    COALESCE(
        NULLIF(TRIM(customer_name), ''),
        'Unknown'
    ) AS customer_name,
    INITCAP(TRIM(region)) AS region,
    TRIM(product) AS product,
    TRIM(category) AS category,
    ABS(quantity) AS quantity,
    COALESCE(price, 0) AS price,
    TRY_TO_NUMBER(NULLIF(TRIM(discount), '')) AS discount,
    ABS(quantity) *
    COALESCE(price, 0) *
    (1 - COALESCE(TRY_TO_NUMBER(NULLIF(TRIM(discount), '')), 0))
    AS total_amount

FROM raw_layer.raw_data;

STEP 3 — DATA VALIDATION

3.1 Check Still Null Dates
SELECT COUNT(*) AS null_dates_after_cleaning
FROM staging_layer.cleaned_data
WHERE order_date IS NULL;

3.2 Validate Total Amount Logic
SELECT *
FROM staging_layer.cleaned_data
WHERE total_amount != quantity * price * (1 - COALESCE(discount,0));

3.3 Check “Unknown” Customers
SELECT COUNT(*) AS unknown_customers
FROM staging_layer.cleaned_data
WHERE customer_id = 'Unknown';

STEP 4 — DEDUPLICATION (Here Business Key = order_id)

4.1 First Check Duplicates
SELECT order_id, COUNT(*) AS duplicate_count
FROM staging_layer.cleaned_data
GROUP BY order_id
HAVING COUNT(*) > 1;

4.2 Create Deduplicated Table
CREATE OR REPLACE TABLE staging_layer.cleaned_deduplicated AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY order_id
               ORDER BY 
                   CASE WHEN order_date IS NULL THEN 1 ELSE 0 END,
                   order_date DESC
           ) AS rn
    FROM staging_layer.cleaned_data
)
WHERE rn = 1;

STEP 5 — FINAL QUALITY CHECK
  
5.1 Final Record Count Check
SELECT COUNT(*) FROM raw_layer.raw_data;
SELECT COUNT(*) FROM staging_layer.cleaned_data;
SELECT COUNT(*) FROM staging_layer.cleaned_deduplicated;

5.2 Check Duplicates Removed
SELECT order_id, COUNT(*)
FROM staging_layer.cleaned_deduplicated
GROUP BY order_id
HAVING COUNT(*) > 1;


















