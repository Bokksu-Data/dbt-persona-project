{{ config(materialized='table') }}

WITH flavor_categories AS (
SELECT * from ref{{('int__collection_cleaning')}}
),


--how much a customer bought, how many, when...
customer_collections AS (
SELECT l.composite_customer_id, fc.collection_title, fc.flavor as flavors, fc.lineitem_type as brand_name,
COUNT(DISTINCT l.composite_order_id) as total_orders,
COUNT(DISTINCT l.composite_customer_id) as unique_customers,
SUM(l.lineitem_quantity) as total_units_sold,
SUM(l.lineitem_net_revenue_at_quantity) as total_spent,
MIN(l.CREATED_AT_EST::date) as first_order_date,
MAX(l.CREATED_AT_EST::date) as most_recent_order_date

FROM bokksu._core.fct__all__lineitems l LEFT JOIN flavor_categories fc ON l.composite_product_variant_id = fc.composite_product_variant_id

--filtering
WHERE 

l.cancelled_at_est is null and 
l.lineitem_net_revenue_at_quantity > 0 and 
l.composite_customer_id IS NOT NULL 

GROUP BY l.composite_customer_id, fc.collection_title, flavors, brand_name
)

SELECT 
composite_customer_id,
collection_title, flavors, brand_name,
COUNT(DISTINCT collection_title) as number_of_collections_bought,
SUM(total_units_sold) as total_units_sold_all_collections,
SUM(total_spent) as total_spent_all_collections,
MIN(first_order_date) as first_ever_order,
MAX(most_recent_order_date) as most_recent_order

FROM customer_collections
GROUP BY composite_customer_id, collection_title, flavors, brand_name
ORDER BY total_spent_all_collections DESC
