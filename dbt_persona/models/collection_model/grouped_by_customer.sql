{{ config(materialized='table') }}

WITH 

products AS 
(
SELECT * from {{ref('int__collection_cleaning')}}
),


--how much a customer bought, how many, when...
customer_collections AS (
SELECT 
l.composite_customer_id, 
l.composite_product_variant_id,
l.lineitem_name as product_name,
l.lineitem_sku,
brand,
flavor,
p.COLLECTION_NAMES_ARRAY,

COUNT(DISTINCT l.composite_order_id) as total_orders,
COUNT(DISTINCT l.composite_customer_id) as unique_customers,
SUM(l.lineitem_quantity) as total_units_sold,
SUM(l.lineitem_net_revenue_at_quantity) as total_spent,
MIN(l.CREATED_AT_EST::date) as first_order_date,
MAX(l.CREATED_AT_EST::date) as most_recent_order_date

FROM bokksu._core.fct__all__lineitems l 
LEFT JOIN products as p ON l.composite_product_variant_id = p.composite_product_variant_id

--filtering
WHERE 
brand in ('SGM', 'MKT', 'BTQ') and
l.cancelled_at_est is null and 
l.lineitem_net_revenue_at_quantity > 0 and 
l.composite_customer_id IS NOT NULL 

GROUP BY 1,2,3,4,5,6,7
)

select * from customer_collections

-- SELECT 
-- composite_customer_id,
-- product_variant_id, 
-- flavor_type,
--  brand_name,
-- COUNT(DISTINCT collection_title) as number_of_collections_bought,
-- SUM(total_units_sold) as total_units_sold_all_collections,
-- SUM(total_spent) as total_spent_all_collections,
-- MIN(first_order_date) as first_ever_order,
-- MAX(most_recent_order_date) as most_recent_order

-- FROM customer_collections
-- GROUP BY 1,2,3,4,5
-- ORDER BY total_spent_all_collections DESC
