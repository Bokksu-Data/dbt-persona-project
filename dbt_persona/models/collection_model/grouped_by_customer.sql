{{ config(materialized='table') }}

WITH flavor_categories AS (
SELECT p.composite_product_variant_id, p.flavor_type, p.lineitem_type,
TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(u.collection_title, '(QUIZ)', ''),'JANUARY', ''),'FEBRUARY', ''),'MARCH', ''),'APRIL', ''),'MAY', ''),'JUNE', ''),'JULY', ''),'AUGUST', ''),'SEPTEMBER', ''),'OCTOBER', ''),'NOVEMBER', ''),'DECEMBER', ''),'+', ''),'.', ''),':', ''),'0', ''),'1', ''),'2', ''),'3', ''),'4', ''),'5', ''),'6', ''),'7', ''),'8', ''),'9', '')) as collection_title,
p.flavor_type as flavor
FROM BOKKSU._core.dim__all__products p LEFT JOIN BOKKSU._OPERATIONS.DIM_UNIVERSAL_PRODUCTS_COLLECTIONS u ON p.composite_product_variant_id = u.composite_product_variant_id
WHERE p.flavor_type IS NOT NULL
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
fc.collection_title != 'ALL' and 
fc.collection_title not like 'ALL%' and 
fc.collection_title not like '%SUBSCRIPTIONS%' and 
fc.collection_title not like '%SUBSCRIPTION%' and  
fc.collection_title NOT LIKE '%BOX%' AND 
fc.collection_title NOT LIKE '%1-MONTH%' AND 
fc.collection_title NOT LIKE '%HOME PAGE%' and 
fc.collection_title NOT LIKE '%PREORDER%' AND 
fc.collection_title NOT LIKE '%JAPAN CRATE%'

and 
l.cancelled_at_est is null and 
l.lineitem_net_revenue_at_quantity > 0 and 
l.composite_customer_id IS NOT NULL and 
(fc.lineitem_type = 'SM' OR fc.lineitem_type like 'MKT%' OR fc.lineitem_type like 'BTQ%')

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
