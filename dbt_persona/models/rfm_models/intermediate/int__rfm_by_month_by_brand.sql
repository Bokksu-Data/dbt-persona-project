{{
    config(
        materialized = "table"
    )
}}
-- Year_Number + Month of Year

/*
COMPOSITE_CUSTOMER_ID = user_id (Unique identifier for each user or customer)
CREATED_AT_EST = payment_date (Date of each customer's payment)
COMPOSITE_ORDER_ID = payment_id (Unique identifier of each payment)
TOTAL_NET_REVENUE = payment_amount (Transacted amount of each payment)
*/
-- Loading payments data
with payments as (
    select 
        distinct
        COMPOSITE_CUSTOMER_ID as user_id, 
        CREATED_AT_EST::date as payment_date, 
        COMPOSITE_ORDER_ID as payment_id, 
        'SNB' as BRAND,
        PL_REVENUE as payment_amount
    from BOKKSU._CORE.FCT__SN_BOX__ORDERS
    where cancelled_at_est is null
    union all 
    select 
        distinct
        COMPOSITE_CUSTOMER_ID as user_id, 
        CREATED_AT_EST::date as payment_date, 
        COMPOSITE_ORDER_ID as payment_id, 
        'BTQ' as BRAND,
        PL_REVENUE as payment_amount
    from BOKKSU._CORE.FCT__BTQ__ORDERS
    where cancelled_at_est is null
    union all
    select 
        distinct
        COMPOSITE_CUSTOMER_ID as user_id, 
        CREATED_AT_EST::date as payment_date, 
        COMPOSITE_ORDER_ID as payment_id, 
        'MKT' as BRAND,
        PL_REVENUE as payment_amount
    from BOKKSU._CORE.FCT__MKT__ORDERS
    where cancelled_at_est is null
    union all
    select 
        distinct
        COMPOSITE_CUSTOMER_ID as user_id, 
        CREATED_AT_EST::date as payment_date, 
        COMPOSITE_ORDER_ID as payment_id, 
        'SGM' as BRAND,
        PL_REVENUE as payment_amount
    from BOKKSU._CORE.FCT__SM__ORDERS
    where cancelled_at_est is null
), 

months AS( -- Queries calendar table and selects the date_month column
    SELECT DISTINCT MONTH_START_DATE::date AS date_month
    FROM {{ref('dim__calendar')}}
    where MONTH_START_DATE <= date_trunc('month', current_date)
    and MONTH_START_DATE >= '2019-01-01'
),

payments_with_months AS(
    SELECT  
        distinct
        user_id,
        brand,
        date_month,
        payment_date,
        payment_id,
        payment_amount
    FROM months
        JOIN payments ON date_trunc('month', payment_date) <= date_month
),

-- select * from payments_with_months
/*
 max_payment_date (Last payment date of each user. We keep it for auditing)
 recency (Months that passed between the last transaction of each user and today)
 frequency (Quantity of user transactions in the analyzed window)
 monetary (Transacted amount by the user in the analyzed window)
*/
-- Calculate the RFM for each user
rfm_values AS (
    SELECT  
        user_id, 
        brand,
        date_month,
        MAX(payment_date) AS max_payment_date,
        date_month - MAX(date_trunc('month', payment_date)) AS recency,
        COUNT(DISTINCT payment_id) AS frequency,
        SUM(payment_amount) AS monetary
    FROM payments_with_months
    GROUP BY user_id, brand, date_month
), 

-- Dividing Users based on RFM values
rfm_percentiles AS (
    SELECT  
        user_id,
        brand,
        date_month,
        max_payment_date,
        recency,
        frequency,
        monetary,
        PERCENT_RANK() OVER (PARTITION BY BRAND ORDER BY recency DESC) AS recency_percentile,
        PERCENT_RANK() OVER (PARTITION BY BRAND ORDER BY frequency ASC) AS frequency_percentile,
        PERCENT_RANK() OVER (PARTITION BY BRAND ORDER BY monetary ASC) AS monetary_percentile
    FROM rfm_values
)

select * from rfm_percentiles