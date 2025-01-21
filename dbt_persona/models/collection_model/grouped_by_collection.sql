{{ config(materialized='table') }}

WITH flavor_categories AS (

SELECT * from ref{{('int__collection_cleaning')}}

),

collection_performance AS (
SELECT 
    fc.collection_title, 
    fc.flavor as flavors, fc.lineitem_type as brand_name,
    COUNT(DISTINCT l.composite_customer_id) as unique_customers,
    COUNT(DISTINCT l.composite_order_id) as total_orders,
    SUM(l.lineitem_quantity) as total_units_sold,
    SUM(l.lineitem_net_revenue_at_quantity) as total_revenue,
    MIN(l.CREATED_AT_EST::date) as first_order_date,
    MAX(l.CREATED_AT_EST::date) as most_recent_order_date
FROM bokksu._core.fct__all__lineitems l 
LEFT JOIN flavor_categories fc ON l.composite_product_variant_id = fc.composite_product_variant_id
WHERE l.cancelled_at_est is null
AND l.lineitem_net_revenue_at_quantity > 0
AND l.composite_customer_id IS NOT NULL
AND 
GROUP BY fc.collection_title, flavors, brand_name
)

SELECT *
FROM collection_performance
ORDER BY total_revenue DESC