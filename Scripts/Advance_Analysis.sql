
-- All The Final Outputs Are End Of The File List 

-- =============================================
-- Creating DataBase And Storing Different Table On It 
-- =============================================

CREATE DATABASE olist_sales;
USE olist_sales;

-- =============================================
-- RFM ANALYSIS - Customer Segmentation
-- =============================================

CREATE TABLE customer_rfm_segmentation AS
WITH rfm_calc AS (
    SELECT 
        customer_unique_id,
        MAX(STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')) AS last_purchase_date,
        DATEDIFF('2025-12-31', MAX(STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'))) AS Recency,
        COUNT(DISTINCT order_id) AS Frequency,
        ROUND(SUM(total_value), 2) AS Monetary
    FROM master_sales
    GROUP BY customer_unique_id
),
rfm_score AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY Recency DESC) AS R_Score,      -- Lower recency = higher score
        NTILE(5) OVER (ORDER BY Frequency DESC) AS F_Score,
        NTILE(5) OVER (ORDER BY Monetary DESC) AS M_Score
    FROM rfm_calc
)
SELECT 
    customer_unique_id,
    Recency,
    Frequency,
    Monetary,
    R_Score,
    F_Score,
    M_Score,
    (R_Score + F_Score + M_Score) AS RFM_Score,
    CASE 
        WHEN (R_Score + F_Score + M_Score) >= 13 THEN 'Champions'
        WHEN (R_Score + F_Score + M_Score) >= 11 THEN 'Loyal Customers'
        WHEN (R_Score + F_Score + M_Score) >= 9  THEN 'Potential Loyalists'
        WHEN (R_Score + F_Score + M_Score) >= 7  THEN 'Promising'
        WHEN (R_Score + F_Score + M_Score) >= 5  THEN 'At Risk'
        ELSE 'Lost Customers'
    END AS Customer_Segment
FROM rfm_score
ORDER BY RFM_Score DESC, Monetary DESC;

-- =============================================
-- MoM & YoY Revenue Growth Analysis
-- =============================================

CREATE TABLE revenue_growth AS
WITH monthly_sales AS (
    SELECT 
        DATE_FORMAT(STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'), '%Y-%m') AS yearmonth,
        YEAR(STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')) AS sales_year,
        MONTH(STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')) AS sales_month,
        ROUND(SUM(total_value), 2) AS revenue,
        ROUND(SUM(freight_value), 2) AS total_freight,
        COUNT(DISTINCT order_id) AS total_orders
    FROM master_sales
    GROUP BY yearmonth, sales_year, sales_month
)
SELECT 
    yearmonth,
    revenue,
    total_orders,
    LAG(revenue) OVER (ORDER BY yearmonth) AS prev_month_revenue,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY yearmonth)) 
          / NULLIF(LAG(revenue) OVER (ORDER BY yearmonth), 0) * 100, 2) AS mom_growth_pct,
    LAG(revenue, 12) OVER (ORDER BY yearmonth) AS prev_year_revenue,
    ROUND((revenue - LAG(revenue, 12) OVER (ORDER BY yearmonth)) 
          / NULLIF(LAG(revenue, 12) OVER (ORDER BY yearmonth), 0) * 100, 2) AS yoy_growth_pct
FROM monthly_sales
ORDER BY yearmonth DESC;

-- =============================================
-- Top Product Categories by Sales Contribution
-- =============================================

CREATE TABLE top_product_Categories AS 
WITH category_sales AS (
    SELECT 
        product_category_name_english AS category,
        ROUND(SUM(total_value), 2) AS total_sales,
        SUM(price) AS total_product_value,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT customer_unique_id) AS unique_customers
    FROM master_sales
    GROUP BY product_category_name_english
),
ranked_categories AS (
    SELECT *,
        ROUND(total_sales * 100.0 / SUM(total_sales) OVER (), 2) AS sales_contribution_pct,
        RANK() OVER (ORDER BY total_sales DESC) AS category_rank
    FROM category_sales
)
SELECT * 
FROM ranked_categories 
WHERE category_rank <= 20
ORDER BY total_sales DESC;

-- =============================================
-- Cohort Analysis - Customer Retention Rate
-- =============================================

CREATE TABLE customer_retention AS 
WITH first_purchase AS (
    SELECT 
        customer_unique_id,
        MIN(DATE_FORMAT(STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'), '%Y-%m')) AS cohort_month
    FROM master_sales
    GROUP BY customer_unique_id
),
cohort_data AS (
    SELECT 
        f.cohort_month,
        DATE_FORMAT(STR_TO_DATE(s.order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'), '%Y-%m') AS order_month,
        COUNT(DISTINCT s.customer_unique_id) AS active_customers
    FROM master_sales s
    JOIN first_purchase f ON s.customer_unique_id = f.customer_unique_id
    GROUP BY f.cohort_month, order_month
)
SELECT 
    cohort_month,
    order_month,
    active_customers,
    FIRST_VALUE(active_customers) OVER (PARTITION BY cohort_month ORDER BY order_month) AS cohort_size,
    ROUND(100.0 * active_customers / 
          FIRST_VALUE(active_customers) OVER (PARTITION BY cohort_month ORDER BY order_month), 2) AS retention_rate_pct
FROM cohort_data
ORDER BY cohort_month, order_month;

-- =============================================
-- State-wise Performance with Running Total
-- =============================================

CREATE TABLE state_revenue AS 
SELECT 
    customer_state AS state,
    ROUND(SUM(total_value), 2) AS total_revenue,
    ROUND(SUM(freight_value), 2) AS total_freight,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_unique_id) AS unique_customers,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    ROUND(SUM(CASE WHEN is_late = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_pct,
    ROUND(SUM(SUM(total_value)) OVER (ORDER BY SUM(total_value) DESC), 2) AS running_total_revenue,
    ROUND(SUM(SUM(total_value)) OVER (ORDER BY SUM(total_value) DESC) * 100.0 
          / SUM(SUM(total_value)) OVER (), 2) AS cumulative_pct
FROM master_sales
GROUP BY customer_state
ORDER BY total_revenue DESC;

-- =============================================
-- Delivery Performance + Review Analysis
-- =============================================

CREATE TABLE delivery_performance AS
SELECT 
    is_late,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_days,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(SUM(payment_value), 2) AS total_payment_value
FROM master_sales
GROUP BY is_late
ORDER BY total_orders DESC;

-- =============================================
-- Payment Methods Performance
-- =============================================

CREATE TABLE payment_methods AS 
SELECT 
    payment_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS total_amount,
    ROUND(AVG(payment_installments), 2) AS avg_installments,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS usage_percentage
FROM master_sales
GROUP BY payment_type
ORDER BY total_amount DESC;

-- =============================================
-- Monthly Revenue Trend with Running Total & Moving Average
-- =============================================

CREATE TABLE monthly_revenue_analysi AS
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'), '%Y-%m') AS yearmonth,
        ROUND(SUM(total_value), 2) AS revenue,
        COUNT(DISTINCT order_id) AS orders,
        COUNT(DISTINCT customer_unique_id) AS unique_customers
    FROM master_sales
    GROUP BY yearmonth
)
SELECT 
    yearmonth,
    revenue,
    orders,
    unique_customers,
    ROUND(SUM(revenue) OVER (ORDER BY yearmonth), 2) AS running_total_revenue,           -- Cumulative Revenue
    ROUND(AVG(revenue) OVER (ORDER BY yearmonth ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3_month,  -- 3-month Moving Average
    ROUND(revenue * 100.0 / SUM(revenue) OVER (), 2) AS revenue_contribution_pct,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM monthly_revenue
ORDER BY yearmonth DESC;

-- =============================================
-- Customer Lifetime Value (CLV) Ranking
-- =============================================

CREATE TABLE customer_clv_segmentation AS 
WITH customer_metrics AS (
    SELECT 
        customer_unique_id,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(SUM(total_value), 2) AS total_spent,
        ROUND(AVG(total_value), 2) AS avg_order_value,
        MAX(STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')) AS last_order_date,
        MIN(STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')) AS first_order_date,
        DATEDIFF(MAX(STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')), 
                 MIN(STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'))) AS customer_lifespan_days
    FROM master_sales
    GROUP BY customer_unique_id
),
clv_ranked AS (
    SELECT *,
        ROUND(total_spent / NULLIF(customer_lifespan_days, 0), 2) AS avg_daily_spend,
        NTILE(5) OVER (ORDER BY total_spent DESC) AS clv_score
    FROM customer_metrics
)
SELECT 
    customer_unique_id,
    total_orders,
    total_spent,
    avg_order_value,
    customer_lifespan_days,
    avg_daily_spend,
    clv_score,
    CASE 
        WHEN clv_score = 5 THEN 'High Value'
        WHEN clv_score = 4 THEN 'Above Average'
        WHEN clv_score = 3 THEN 'Average'
        WHEN clv_score = 2 THEN 'Below Average'
        ELSE 'Low Value'
    END AS customer_value_segment
FROM clv_ranked
ORDER BY total_spent DESC;

-- =============================================
-- ABC Analysis - Product Category Importance
-- =============================================

CREATE TABLE category_abc_analysis AS 
WITH category_sales AS (
    SELECT 
        product_category_name_english AS category,
        ROUND(SUM(total_value), 2) AS total_sales,
        COUNT(DISTINCT order_id) AS total_orders
    FROM master_sales
    GROUP BY product_category_name_english
),
abc_calc AS (
    SELECT *,
        ROUND(total_sales * 100.0 / SUM(total_sales) OVER (), 2) AS sales_percentage,
        ROUND(SUM(total_sales) OVER (ORDER BY total_sales DESC) * 100.0 / SUM(total_sales) OVER (), 2) AS cumulative_percentage
    FROM category_sales
)
SELECT 
    category,
    total_sales,
    sales_percentage,
    cumulative_percentage,
    CASE 
        WHEN cumulative_percentage <= 80 THEN 'A - High Priority'
        WHEN cumulative_percentage <= 95 THEN 'B - Medium Priority'
        ELSE 'C - Low Priority'
    END AS abc_category
FROM abc_calc
ORDER BY total_sales DESC;

-- =============================================
-- Customer Churn Risk Analysis
-- =============================================

CREATE TABLE customer_churn_risk_analysis AS 
WITH customer_activity AS (
    SELECT 
        customer_unique_id,
        MAX(STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')) AS last_order_date,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(SUM(total_value), 2) AS total_spent,
        DATEDIFF('2025-12-31', MAX(STR_TO_DATE(order_purchase_timestamp, '%Y-%m-%d %H:%i:%s'))) AS days_since_last_order
    FROM master_sales
    GROUP BY customer_unique_id
)
SELECT 
    customer_unique_id,
    last_order_date,
    total_orders,
    total_spent,
    days_since_last_order,
    CASE 
        WHEN days_since_last_order > 180 AND total_orders = 1 THEN 'High Churn Risk'
        WHEN days_since_last_order > 120 THEN 'Medium Churn Risk'
        WHEN days_since_last_order > 60  THEN 'Low Churn Risk'
        ELSE 'Active Customer'
    END AS churn_risk,
    NTILE(5) OVER (ORDER BY days_since_last_order DESC) AS recency_decile
FROM customer_activity
ORDER BY days_since_last_order DESC;

-- =============================================
-- Seller Performance Ranking
-- =============================================

CREATE TABLE seller_performance AS
SELECT 
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(total_value), 2) AS total_revenue,
    ROUND(AVG(review_score), 2) AS avg_review_score,
    ROUND(AVG(delivery_days), 2) AS avg_delivery_time,
    ROUND(SUM(CASE WHEN is_late = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS late_delivery_pct,
    RANK() OVER (ORDER BY SUM(total_value) DESC) AS revenue_rank,
    RANK() OVER (ORDER BY AVG(review_score) DESC) AS review_rank
FROM master_sales
WHERE seller_id IS NOT NULL
GROUP BY seller_id
HAVING COUNT(DISTINCT order_id) >= 10
ORDER BY total_revenue DESC
LIMIT 30;

-- =============================================
-- All Query Outputs
-- =============================================
-- Identify high-value, loyal, and at-risk customers using RFM analysis?
SELECT * FROM customer_rfm_segmentation;

-- Analyze the year on year and month on month revenue growth?
SELECT * FROM revenue_growth;

-- What are the top 20 product categories based on total sales?
SELECT * FROM top_product_Categories;

-- How do different customer cohorts behave over time in terms of repeat purchases?
SELECT * FROM customer_retention;

-- What is the total revenue and order volume generated from each state?
SELECT * FROM state_revenue;

-- What percentage of orders are delivered late compared to on-time deliveries?
SELECT * FROM delivery_performance;

-- What are the most popular payment methods used by customers?
SELECT * FROM payment_methods ; 

-- Which months generate the highest revenue?
SELECT * FROM monthly_revenue_analysi;

-- Which customers contribute the most revenue over their lifetime?
SELECT * FROM customer_clv_segmentation;

-- Which product categories generate the majority of company revenue?
SELECT * FROM category_abc_analysis;

-- Which customers have not purchased for a long time and may churn?
SELECT * FROM customer_churn_risk_analysis;

-- Which sellers generate the highest revenue and handle the most orders?
SELECT * FROM seller_performance;
