{% macro create_dim_rfm(input_model) -%}
with
int__rfm as
(
    select * from {{ref(input_model)}}
),
-- Assigns score to each RFM value to each user
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
                END AS monetary_score,
            CASE
                WHEN recency_percentile >= 0.8 THEN 1
                WHEN recency_percentile >= 0.6 THEN 2
                WHEN recency_percentile >= 0.4 THEN 3
                WHEN recency_percentile >= 0.2 THEN 4
                ELSE 5
                END AS recency_score_inverse,
            CASE
                WHEN frequency_percentile >= 0.8 THEN 1
                WHEN frequency_percentile >= 0.6 THEN 2
                WHEN frequency_percentile >= 0.4 THEN 3
                WHEN frequency_percentile >= 0.2 THEN 4
                ELSE 5
                END AS frequency_score_inverse,
            CASE
                WHEN monetary_percentile >= 0.8 THEN 1
                WHEN monetary_percentile >= 0.6 THEN 2
                WHEN monetary_percentile >= 0.4 THEN 3
                WHEN monetary_percentile >= 0.2 THEN 4
                ELSE 5
                END AS monetary_score_inverse
    FROM int__rfm
),
-- Segment users by Frequency, Recency, Monetary scores based on proposed R-F matrix
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
rfm_score AS
(
    SELECT *,
        CONCAT(CONCAT(recency_score, frequency_score), monetary_score) AS rfm_score,
        /*
        In this system, the deciles correspond to RFM scores of 1-10.
        So, an RFM score of 1 is the best and covers the top 10% of customers.
        Likewise, a score of 2 corresponds to 11-20%, a score of 3 corresponds to 21-30%, and so on.
        */
        frequency_score_inverse * SQRT(monetary_score_inverse) /  recency_score_inverse AS rfm_score_decile --decile score
    FROM rfm_segment
)
SELECT *
FROM rfm_score
{%- endmacro %}