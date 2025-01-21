{{
    config(
        materialized = "table"
    )
}}

WITH rfm_segments AS(
	SELECT *
	FROM {{ref('dim__rfm_by_month')}}
),	
current_segments AS(
	SELECT *
	FROM rfm_segments
	WHERE date_month = (SELECT MAX(date_month) FROM rfm_segments)
)
SELECT *
FROM current_segments