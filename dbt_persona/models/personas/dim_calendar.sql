-- -- Option 1:
-- CREATE TABLE dim_calendar(
--     date_day DATE 
-- )
-- SELECT CREATED_AT_EST::date
-- INTO dim_calendar
-- FROM BOKKSU._CORE.FCT__ALL__ORDERS
-- WHERE CREATED_AT_EST::date BETWEEN CURRENT_DATE AND 2016-01-01
-- -- Jan 16 - today (dates of purchases)

--Option 2:
-- CREATE TABLE dim_calendar AS 
--     select CREATED_AT_EST::date
--     FROM BOKKSU._CORE.FCT__ALL__ORDERS
--     WHERE CREATED_AT_EST::date BETWEEN CURRENT_DATE AND 2016-01-01

-- -- Option 3:
--     INSERT INTO dim_calendar (date_day) 
--         VALUES(CREATED_AT_EST::date)
--     FROM BOKKSU._CORE.FCT__ALL__ORDERS
--     WHERE CREATED_AT_EST::date BETWEEN CURRENT_DATE AND 2016-01-01

-- -- Option 4:
-- CREATE TABLE dim_calendar AS 
--     select CREATED_AT_EST::date
--     FROM BOKKSU._CORE.FCT__ALL__ORDERS
--     WHERE CREATED_AT_EST::date BETWEEN CURRENT_DATE AND 2016-01-01

-- TODO:
-- Search up dbt calendar table -> Row Over. Or install libraries like dbt date to create the calendar table
-- One of the from statements is incorrect in RFM_model

-- models/dim_calendar.sql

{{
    config(
        materialized = "table"
    )
}}

{{ dbt_date.get_date_dimension("2019-01-01", "2027-01-01") }}