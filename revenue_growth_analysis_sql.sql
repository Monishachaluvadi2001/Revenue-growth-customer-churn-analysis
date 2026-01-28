create database revenue_growth_analysis
go

use revenue_growth_analysis

select DB_NAME() as current_database

USE revenue_growth_analysis;
GO

SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS distinct_orders
FROM dbo.olist_orders;

SELECT top 5 * from dbo.olist_orders


/* ============================================================
 Day 6 – Data Modeling & Customer Behavior Foundations (SQL)

 Purpose of Day 6:
 -----------------
 Day 6 is where the project transitions from raw data analysis
 into a structured analytical model that supports:
 - Customer behavior analysis
 - Retention & churn logic
 - Time-based reporting
 - Scalable business insights

 Up to Day 5:
 ------------
 - We explored revenue, orders, and customers
 - We validated data quality and fixed missing values
 - Analysis was mostly table-by-table and exploratory

 What changes on Day 6:
 ---------------------
 We stop treating CSVs as flat files and start treating the data
 like a real analytics system.

 We introduce:
 - Fact tables (events like orders)
 - Dimension tables (customers, dates)
 - Business-ready metrics (recency, churn, activity)

 Core idea:
 ----------
 One clean source of truth that can answer:
 - Who are our customers?
 - When did they last purchase?
 - Are they active or churned?
 - How does behavior change over time?

 What we will do in Day 6:
 ------------------------
 Step 1: Import core datasets correctly (no quoted column issues)
 Step 2: Identify fact vs dimension tables
 Step 3: Build a clean customer-order base table
 Step 4: Calculate recency and churn (business logic)
 Step 5: Introduce a date dimension for time analysis
 Step 6: Validate joins and model sanity
 Step 7: Final Day 6 checks before advanced analytics

 Important note:
 ---------------
 Day 6 is NOT about charts or KPIs.
 It is about building the backbone that makes
 future insights correct, explainable, and reusable.

============================================================ */

/* ============================================================
 Step 1: Verify Import + Create Clean Orders Table

 Goal:
 - Confirm dbo.olist_orders exists and looks correct
 - Inspect columns + row counts
 - Create a typed, clean table dbo.orders_clean
   (so future steps are stable and readable)

 Note:
 - If you see red underlines but queries run, it’s usually
   SSMS IntelliSense lag (Ctrl+Shift+R to refresh).
============================================================ */

USE revenue_growth_analysis;
GO

/* ------------------------------------------------------------
 1.1 Confirm the table exists
------------------------------------------------------------ */
SELECT
    s.name AS schema_name,
    t.name AS table_name
FROM sys.tables t
JOIN sys.schemas s ON t.schema_id = s.schema_id
WHERE t.name = 'olist_orders';
GO

/* ------------------------------------------------------------
 1.2 Quick preview (sanity check)
------------------------------------------------------------ */
SELECT TOP (10) *
FROM dbo.olist_orders;
GO

/* ------------------------------------------------------------
 1.3 Row count
------------------------------------------------------------ */
SELECT COUNT(*) AS total_rows
FROM dbo.olist_orders;
GO

/* ------------------------------------------------------------
 1.4 Column list + datatypes (this tells us what the import did)
------------------------------------------------------------ */
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME   = 'olist_orders'
ORDER BY ORDINAL_POSITION;
GO

/* ------------------------------------------------------------
 1.5 Date range check (works whether the column is text or datetime)
 IMPORTANT:
 - If order_purchase_timestamp is text, TRY_CONVERT will still work.
 - If it's already datetime, TRY_CONVERT will also work.
------------------------------------------------------------ */
SELECT
    MIN(TRY_CONVERT(datetime2(0), [order_purchase_timestamp], 121)) AS first_order_ts,
    MAX(TRY_CONVERT(datetime2(0), [order_purchase_timestamp], 121)) AS last_order_ts,
    SUM(CASE WHEN TRY_CONVERT(datetime2(0), [order_purchase_timestamp], 121) IS NULL THEN 1 ELSE 0 END) AS bad_timestamp_rows
FROM dbo.olist_orders;
GO

/* ------------------------------------------------------------
 1.6 Create a CLEAN typed table (recommended)
 Why:
 - Avoids future headaches with mixed datatypes and quoting.
 - We’ll build all Day 6 logic on dbo.orders_clean, not raw import.
------------------------------------------------------------ */
DROP TABLE IF EXISTS dbo.orders_clean;
GO

SELECT
    CAST([order_id] AS varchar(50))                    AS order_id,
    CAST([customer_id] AS varchar(50))                 AS customer_id,
    CAST([order_status] AS varchar(30))                AS order_status,

    TRY_CONVERT(datetime2(0), [order_purchase_timestamp], 121)  AS order_purchase_ts,
    TRY_CONVERT(datetime2(0), [order_approved_at], 121)         AS order_approved_ts,
    TRY_CONVERT(datetime2(0), [order_delivered_carrier_date], 121) AS delivered_carrier_ts,
    TRY_CONVERT(datetime2(0), [order_delivered_customer_date], 121) AS delivered_customer_ts,
    TRY_CONVERT(datetime2(0), [order_estimated_delivery_date], 121) AS estimated_delivery_ts

INTO dbo.orders_clean
FROM dbo.olist_orders;
GO

/* ------------------------------------------------------------
 1.7 Validate the clean table
------------------------------------------------------------ */
SELECT TOP (10) *
FROM dbo.orders_clean
ORDER BY order_purchase_ts DESC;
GO

SELECT
    COUNT(*) AS total_rows_clean,
    SUM(CASE WHEN order_purchase_ts IS NULL THEN 1 ELSE 0 END) AS null_purchase_ts
FROM dbo.orders_clean;
GO


/* ============================================================
 Step 2: Fact vs Dimension Model (SQL Analytics)

 What we have now:
 - dbo.orders_clean  (cleaned version of orders)

 What this step does:
 - Defines the analytical model (star schema thinking)
 - Decides which tables are Facts vs Dimensions
 - Sets the plan for which CSVs to import next

 Why this matters:
 - Facts are where metrics come from (counts, revenue, retention)
 - Dimensions are how we slice metrics (customer, product, time)
============================================================ */

USE revenue_growth_analysis;
GO

/* ------------------------------------------------------------
 2.1 Fact tables (events / transactions)
------------------------------------------------------------ */
-- Fact: Orders (one row per order)
-- Table: dbo.orders_clean
-- Metrics we can already compute from orders:
-- - total orders
-- - orders per customer
-- - order timeline
-- - churn/recency based on purchase dates

/* ------------------------------------------------------------
 2.2 Dimension tables (context / descriptors)
------------------------------------------------------------ */
-- Dim: Customers
-- Needed for stable customer identity and future location analysis
-- CSV to import next: olist_customers_dataset.csv
-- Target table name: dbo.customers_raw (then we’ll clean it)

-- Dim: Date
-- We can generate this from dbo.orders_clean (no CSV needed)
-- Useful for month/year grouping and cohorts

-- Dim: Products / Categories (later)
-- CSVs to import later:
-- - olist_products_dataset.csv
-- - product_category_name_translation.csv (optional)
-- Used for product/category revenue analysis in SQL

-- Fact: Order items (later)
-- CSV to import later: olist_order_items_dataset.csv
-- Needed for revenue (price + freight) at item level

-- Fact: Payments (optional later)
-- CSV: olist_order_payments_dataset.csv
-- Alternative revenue source

/* ------------------------------------------------------------
 2.3 What we can do next with only orders (no more imports yet)
------------------------------------------------------------ */
-- Next step (Step 3):
-- Build customer-level base table from dbo.orders_clean:
-- - first_order_ts
-- - last_order_ts
-- - total_orders
--   Then compute:
-- - recency_days
-- - churn flag
GO

/* ============================================================
 Step 3: Build Customer-Level Base Table (from Orders)

 Goal:
 - Create ONE row per customer_id with core behavioral metrics:
   1) first_order_ts  -> earliest purchase timestamp
   2) last_order_ts   -> most recent purchase timestamp
   3) total_orders    -> number of distinct orders

 Why this matters:
 - This customer base table is the foundation for:
   - Recency calculation
   - Churn flagging
   - Cohort/retention analysis (later)
   - Segmentation logic (later)

 Input table:
 - dbo.orders_clean   (clean, typed orders table)

 Assumption:
 - Only 'delivered' orders represent completed purchases.
============================================================ */

USE revenue_growth_analysis;
GO


/* ------------------------------------------------------------
 3.1 Create customer_orders_base (one row per customer)
------------------------------------------------------------ */

DROP TABLE IF EXISTS dbo.customer_orders_base;
GO

SELECT
    customer_id,
    MIN(order_purchase_ts) AS first_order_ts,
    MAX(order_purchase_ts) AS last_order_ts,
    COUNT(DISTINCT order_id) AS total_orders
INTO dbo.customer_orders_base
FROM dbo.orders_clean
WHERE order_status = 'delivered'
  AND order_purchase_ts IS NOT NULL
GROUP BY customer_id;
GO


/* ------------------------------------------------------------
 3.2 Quick validation checks
------------------------------------------------------------ */

-- Preview the most active customers
SELECT TOP (10) *
FROM dbo.customer_orders_base
ORDER BY total_orders DESC;
GO

-- How many customers do we have?
SELECT COUNT(*) AS total_customers
FROM dbo.customer_orders_base;
GO

-- Date boundaries (should align with orders_clean)
SELECT
    MIN(first_order_ts) AS earliest_first_order,
    MAX(last_order_ts)  AS latest_last_order
FROM dbo.customer_orders_base;
GO

-- Logical validation (should be zero)
SELECT COUNT(*) AS invalid_rows
FROM dbo.customer_orders_base
WHERE first_order_ts > last_order_ts;
GO


/* ------------------------------------------------------------
 3.3 Order frequency distribution (how many customers place 1,2,3... orders)
------------------------------------------------------------ */
SELECT
    total_orders,
    COUNT(*) AS customer_count
FROM dbo.customer_orders_base
GROUP BY total_orders
ORDER BY total_orders;
GO

/* ============================================================
 Day 6 – Step 4: Recency + Churn Flag (SQL Server)

 Input:  dbo.customer_orders_base
 Output: dbo.customer_recency_base

 Business rule (simple):
 - churned = no purchase in last 90 days
============================================================ */

USE revenue_growth_analysis;
GO

/* 4.1 Define analysis date as the latest last_order_ts in the dataset */
DECLARE @analysis_date DATETIME2;

SELECT
    @analysis_date = MAX(last_order_ts)
FROM dbo.customer_orders_base;

SELECT @analysis_date AS analysis_date;


/* 4.2 Create customer_recency_base with recency + churn flag */
DROP TABLE IF EXISTS dbo.customer_recency_base;


SELECT
    customer_id,
    first_order_ts,
    last_order_ts,
    total_orders,
    DATEDIFF(DAY, last_order_ts, @analysis_date) AS recency_days,
    CASE
        WHEN DATEDIFF(DAY, last_order_ts, @analysis_date) > 90 THEN 1
        ELSE 0
    END AS is_churned
INTO dbo.customer_recency_base
FROM dbo.customer_orders_base;


/* 4.3 Sanity checks */
-- churn split
SELECT
    is_churned,
    COUNT(*) AS customer_count
FROM dbo.customer_recency_base
GROUP BY is_churned;


-- top most inactive customers (largest recency)
SELECT TOP (10)
    *
FROM dbo.customer_recency_base
ORDER BY recency_days DESC;
GO

USE revenue_growth_analysis;
GO

/* ============================================================
 Step 5: Customer Segmentation (Recency + Frequency)
 Creates a practical customer_segments table for analysis.
============================================================ */

DROP TABLE IF EXISTS dbo.customer_segments;
GO

SELECT
    customer_id,
    first_order_ts,
    last_order_ts,
    total_orders,
    recency_days,
    is_churned,

    /* RF Segments (simple + interpretable) */
    CASE
        WHEN is_churned = 1 THEN 'Churned'
        WHEN recency_days <= 30 AND total_orders >= 3 THEN 'Loyal / High Value'
        WHEN recency_days <= 30 AND total_orders = 2 THEN 'Returning'
        WHEN recency_days <= 30 AND total_orders = 1 THEN 'New'
        WHEN recency_days BETWEEN 31 AND 90 AND total_orders >= 2 THEN 'At Risk (Returning)'
        WHEN recency_days BETWEEN 31 AND 90 AND total_orders = 1 THEN 'At Risk (New)'
        ELSE 'Active (Other)'
    END AS rf_segment,

    /* Baic english reason for the label */
    CONCAT(
        'Recency=', recency_days,
        ' days; Orders=', total_orders,
        '; Churn=', is_churned
    ) AS segment_reason
INTO dbo.customer_segments
FROM dbo.customer_recency_base;
GO

/* Segment counts */
SELECT
    rf_segment,
    COUNT(*) AS customer_count
FROM dbo.customer_segments
GROUP BY rf_segment
ORDER BY customer_count DESC;
GO

/* top rows */
SELECT TOP (20) *
FROM dbo.customer_segments
ORDER BY recency_days ASC, total_orders DESC;
GO

USE revenue_growth_analysis;
GO

/* ============================================================
 Step 6: Customer Segment Activity Over Time
 Understand when different segments were active
============================================================ */

SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,
    cs.rf_segment,
    COUNT(DISTINCT o.customer_id) AS active_customers,
    COUNT(o.order_id) AS total_orders
FROM dbo.olist_orders o
JOIN dbo.customer_segments cs
    ON o.customer_id = cs.customer_id
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp),
    cs.rf_segment
ORDER BY
    order_year,
    order_month,
    cs.rf_segment;
GO

select top 10 * from dbo.olist_order_payments

/* ============================================================
 Step 6.1: Order-level revenue
 Purpose:
 - Aggregate payments so each order has one revenue value
============================================================ */


DROP TABLE IF EXISTS dbo.order_revenue;
GO

SELECT
    order_id,
    SUM(CAST(payment_value AS DECIMAL(10,2))) AS total_payment_value
INTO dbo.order_revenue
FROM dbo.olist_order_payments
GROUP BY order_id;
GO

SELECT TOP 10 *
FROM dbo.order_revenue
ORDER BY total_payment_value DESC;

/* ============================================================
Step 6.2: Monthly revenue by customer segment
============================================================ */

SELECT
    YEAR(o.order_purchase_timestamp)  AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,
    cs.rf_segment,
    COUNT(DISTINCT o.customer_id)     AS active_customers,
    COUNT(o.order_id)                 AS total_orders,
    SUM(r.total_payment_value)        AS total_revenue
FROM dbo.olist_orders o
JOIN dbo.order_revenue r
    ON o.order_id = r.order_id
JOIN dbo.customer_segments cs
    ON o.customer_id = cs.customer_id
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp),
    cs.rf_segment
ORDER BY
    order_year,
    order_month,
    cs.rf_segment;
GO



/* ============================================================
 Day 6 – Customer Behavior & Revenue Analysis (in SQL)

 Objective of Day 6:
 The goal of Day 6 was to use SQL to understand
 customer behavior and revenue at a high level.
 This step focuses on who the customers are,
 how active they are, and how revenue is generated.

 ------------------------------------------------------------
 What we built in Day 6 (simple explanation):
 ------------------------------------------------------------

 1. Customer-level metrics:
    - Created a customer base table using orders data
    - Identified:
        • First order date
        • Last order date
        • Total number of orders per customer

 2. Recency & churn logic:
    - Defined an analysis date using the latest order date
    - Calculated recency (days since last purchase)
    - Marked customers as:
        • Churned (no purchase in last 90 days)
        • Active / New / At Risk

 3. Customer segmentation:
    - Segmented customers into simple business-friendly groups:
        • New
        • At Risk (New)
        • Churned
    - Avoided complex RFM scoring to keep the project clean
      and beginner-friendly.

 4. Payment & revenue preparation:
    - Imported order payments data
    - Aggregated multiple payments per order
    - Created a clean order-level revenue table
      (one row per order with total revenue)

 5. Time-based analysis:
    - Combined orders, customers, and segments
    - Analyzed monthly customer activity and orders
      by customer segment.

 ------------------------------------------------------------
 Key outcome of Day 6:
 ------------------------------------------------------------
 We now have clean, analysis-ready SQL tables that answer:
 - Who are our customers?
 - Which customers are churned or at risk?
 - How does revenue and activity change over time?
 - How different customer segments contribute to business performance?

 This completes the SQL foundation of the project.
 Further insights and visuals will be created outside SQL.
============================================================ */