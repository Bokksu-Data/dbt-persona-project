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
    select COMPOSITE_CUSTOMER_ID as user_id, CREATED_AT_EST::date as payment_date, COMPOSITE_ORDER_ID as payment_id, TOTAL_NET_REVENUE as payment_amount
    from BOKKSU._CORE.FCT__ALL__ORDERS
), 
months AS( -- Queries calendar table and selects the date_month column
	SELECT CURRENT_DATE AS date_month
    UNION ALL
    SELECT DISTINCT MONTH_START_DATE AS date_month
    FROM {{ref('dim_calendar')}}
), 
payments_with_months AS(
    SELECT  user_id,
            date_month,
            payment_date,
            payment_id,
            payment_amount
    FROM months
        JOIN payments ON payment_date <= date_month
),
/*
 max_payment_date (Last payment date of each user. We keep it for auditing)
 recency (Months that passed between the last transaction of each user and today)
 frequency (Quantity of user transactions in the analyzed window)
 monetary (Transacted amount by the user in the analyzed window)
*/
-- Calculate the RFM for each user
rfm_values AS (
    SELECT  user_id, 
            date_month,
            MAX(payment_date) AS max_payment_date,
            date_month - MAX(payment_date) AS recency,
            COUNT(DISTINCT payment_id) AS frequency,
            SUM(payment_amount) AS monetary
    FROM payments_with_months
    GROUP BY user_id, date_month
), -- Dividing Users based on RFM values
rfm_percentiles AS (
    SELECT  user_id,
            date_month,
            recency,
            frequency,
            monetary,
            PERCENT_RANK() OVER (ORDER BY recency DESC) AS recency_percentile,
            PERCENT_RANK() OVER (ORDER BY frequency ASC) AS frequency_percentile,
            PERCENT_RANK() OVER (ORDER BY monetary ASC) AS monetary_percentile
    FROM rfm_values
), -- Assigns score to each RFM value to each user
rfm_scores AS(
    SELECT  *,
            CASE
                WHEN recency_percentile >= 0.8 THEN 5
                WHEN recency_percentile >= 0.6 THEN 4
                WHEN recency_percentile >= 0.4 THEN 3
                WHEN recency_percentile >= 0.2 THEN 2
                ELSE 1
                END AS recency_score,
            CASE
                WHEN frequency_percentile >= 0.8 THEN 5
                WHEN frequency_percentile >= 0.6 THEN 4
                WHEN frequency_percentile >= 0.4 THEN 3
                WHEN frequency_percentile >= 0.2 THEN 2
                ELSE 1
                END AS frequency_score,
            CASE
                WHEN monetary_percentile >= 0.8 THEN 5
                WHEN monetary_percentile >= 0.6 THEN 4
                WHEN monetary_percentile >= 0.4 THEN 3
                WHEN monetary_percentile >= 0.2 THEN 2
                ELSE 1
                END AS monetary_score
    FROM rfm_percentiles
), -- Segment users by Frequency, Recency, Monetary scores based on proposed R-F matrix
rfm_segment AS(
SELECT *,
        CASE
            WHEN recency_score <= 2
                AND frequency_score <= 2 THEN 'Hibernating'
            WHEN recency_score <= 2
                AND frequency_score <= 4 THEN 'At Risk'
            WHEN recency_score <= 2
                AND frequency_score <= 5 THEN 'Cannot Lose Them'
            WHEN recency_score <= 3
                AND frequency_score <= 2 THEN 'About to Sleep'
            WHEN recency_score <= 3
                AND frequency_score <= 3 THEN 'Need Attention'
            WHEN recency_score <= 4
                AND frequency_score <= 1 THEN 'Promising'
            WHEN recency_score <= 4
                AND frequency_score <= 3 THEN 'Potential Loyalists'
            WHEN recency_score <= 4
                AND frequency_score <= 5 THEN 'Loyal Customers'
            WHEN recency_score <= 5
                AND frequency_score <= 1 THEN 'New Customers'
            WHEN recency_score <= 5
                AND frequency_score <= 3 THEN 'Potential Loyalists'
            ELSE 'Champions'
        END AS rfm_segment
FROM  rfm_scores
),
rfm_score AS(
    SELECT *,
        CONCAT(CONCAT(recency_score, frequency_score), monetary_score) AS rfm_score,
        frequency_score * SQRT(monetary_score) /  recency_score AS rfm_score_value
    FROM rfm_segment
)

SELECT *
FROM rfm_score