
/*
    Welcome to your first dbt model!
    Did you know that you can also configure models directly within SQL files?
    This will override configurations stated in dbt_project.yml

    Try changing "table" to "view" below
*/

{{ config(materialized='table') }}


-- select * from bokksu._core.fct__all__orders
-- limit 100

-- select distinct CHANNEL_NAME
-- from BOKKSU._MARKETING.FCT__ALL__MKTG__INFLUENCER_ORDER_METRICS
-- limit 100

select count( distinct COMPOSITE_CUSTOMER_ID) as num_distinct_composite_id
from BOKKSU._CORE.FCT__ALL__ORDERS
where ALL_PL_CUSTOMER_STATUS not in ('PREPAID', 'RENEWAL') and 
created_at_est::date >= dateadd(day, -90, current_date)

/*
    Uncomment the line below to remove records with null `id` values
*/

-- where id is not null

-- Research core and marketing tables