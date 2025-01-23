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
with 

products AS (
    SELECT 
    distinct 
    p.COMPOSITE_PRODUCT_ID,
    p.composite_product_variant_id, 
    p.product_price,
    p.product_cost, 
    p.lineitem_type,
    p.flavor_type as flavor,
    p.final_pl_type as brand,
    product_published_at_utc,
    product_status

    FROM BOKKSU._core.dim__all__products as p 
    where BRAND in ('SGM', 'MKT', 'BTQ')
),

payments as (
    select
        distinct
        l.COMPOSITE_PRODUCT_VARIANT_ID as p_id,
        l.CREATED_AT_EST::date as payment_date,
        LINEITEM_QUANTITY,
        LINEITEM_NET_PRICE,
        -- COST,
        -- CURRENT_PRODUCT_COST,
        lineitem_net_revenue_at_quantity as payment_amount,
        p.brand as BRAND,
        p.product_published_at_utc,
        p.product_status,
        p.flavor
    from BOKKSU._CORE.FCT__ALL__LINEITEMS as l
    left join products as p on p.composite_product_variant_id = l.composite_product_variant_id
    where cancelled_at_est is null 
    and BRAND is not null
    and p.product_status = 'ACTIVE'
    and p.product_published_at_utc is not null
),
months AS( -- Queries calendar table and selects the date_week column
    SELECT DISTINCT WEEK_START_DATE::date AS date_week
    FROM {{ref('dim__calendar')}}
    where WEEK_START_DATE <= date_trunc('week', current_date)
    and WEEK_START_DATE >= '2018-12-30'
    -- and WEEK_START_DATE >= '2023-12-30'
),
payments_with_months AS(
    SELECT  
        distinct 
        p_id,
        date_week,
        payment_date,
        product_published_at_utc,
        product_status,
        BRAND,
        flavor,
        LINEITEM_QUANTITY,
        payment_amount
    FROM months
        JOIN payments ON date_trunc('week', payment_date) <= date_week
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
    SELECT  p_id,
            date_week,
            product_published_at_utc,
            product_status,
            BRAND,
            flavor,
            MAX(payment_date) AS max_payment_date,
            date_week - MAX(date_trunc('week', payment_date)) AS recency,
            SUM(LINEITEM_QUANTITY) AS frequency,
            SUM(payment_amount) AS monetary
    FROM payments_with_months
    WHERE payment_date <= date_week
    GROUP BY 1, 2, 3, 4, 5, 6
),
-- Dividing Users based on RFM values
rfm_percentiles AS (
    SELECT  p_id,
            date_week,
            product_published_at_utc,
            date_trunc('week', product_published_at_utc) as product_cohort_week,
            date_trunc('month', product_published_at_utc) as product_cohort_month,
            product_status,
            BRAND,
            flavor,
            max_payment_date,
            recency,
            frequency,
            monetary,
            PERCENT_RANK() OVER (ORDER BY recency DESC) AS recency_percentile,
            PERCENT_RANK() OVER (ORDER BY frequency ASC) AS frequency_percentile,
            PERCENT_RANK() OVER (ORDER BY monetary ASC) AS monetary_percentile,

            PERCENT_RANK() OVER (PARTITION BY BRAND ORDER BY recency DESC) AS recency_brand_percentile,
            PERCENT_RANK() OVER (PARTITION BY BRAND ORDER BY frequency ASC) AS frequency_brand_percentile,
            PERCENT_RANK() OVER (PARTITION BY BRAND ORDER BY monetary ASC) AS monetary_brand_percentile
    FROM rfm_values
)

select * from rfm_percentiles