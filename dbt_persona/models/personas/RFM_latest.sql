{{
    config(
        materialized = "table"
    )
}}

WITH rfm_segments AS(
	SELECT *
	FROM {{ref('RFM_model')}}
),	
current_segments AS(
	SELECT *
	FROM rfm_segments
	WHERE date_day = (SELECT MAX(date_day) FROM rfm_segments)
)
SELECT *
FROM current_segments