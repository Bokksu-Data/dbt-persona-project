-- Purpose: Query to create an area chart for RFM segments
-- # of customers in a segment / total # of customers
select *
from BOKKSU._PERSONAS.DIM__RFM_BY_WEEK
where date_week >= '2024-10-01'