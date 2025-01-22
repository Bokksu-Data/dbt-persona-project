{{ config(materialized='table') }}

WITH 

clean_collections as 
(
select 
    COMPOSITE_PRODUCT_ID,
    COMPOSITE_COLLECTION_ID,
    TRIM(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(collection_title, '(QUIZ)', ''),'JANUARY', ''),'FEBRUARY', ''),'MARCH', ''),'APRIL', ''),'MAY', ''),'JUNE', ''),'JULY', ''),'AUGUST', ''),'SEPTEMBER', ''),'OCTOBER', ''),'NOVEMBER', ''),'DECEMBER', ''),'+', ''),'.', ''),':', ''),'0', ''),'1', ''),'2', ''),'3', ''),'4', ''),'5', ''),'6', ''),'7', ''),'8', ''),'9', '')
) as collection_title
from bokksu._intermediate.int__all__products__collections as collections
WHERE collection_title != 'ALL'
AND collection_title not like '%ALL%'
AND collection_title not like '%SUBSCRIPTIONS%'
AND collection_title not like '%SUBSCRIPTION%'
AND collection_title NOT LIKE '%BOX%'
AND collection_title NOT LIKE '%1-MONTH%'
AND collection_title NOT LIKE '%HOME PAGE%'
AND collection_title NOT LIKE '%PREORDER%'
AND collection_title NOT LIKE '%JAPAN CRATE%'
),

flavor_categories AS (
SELECT 
distinct 
p.COMPOSITE_PRODUCT_ID,
p.composite_product_variant_id, 
--p.flavor_type, 
p.lineitem_type,
p.flavor_type as flavor,
p.final_pl_type as brand

FROM BOKKSU._core.dim__all__products as p LEFT JOIN Bokksu._operations.dim_universal_products_collections u ON p.composite_product_variant_id = u.composite_product_variant_id
WHERE p.flavor_type IS NOT NULL
AND  (lineitem_type = 'SM' OR lineitem_type like 'MKT%' OR lineitem_type like 'BTQ%')
),

agg_collections AS (
select
    collections.COMPOSITE_PRODUCT_ID,
    LISTAGG(collections.COMPOSITE_COLLECTION_ID, ', ') as COLLECTION_ID_ARRAY,
    LISTAGG(collections.COLLECTION_TITLE, ', ') as COLLECTION_NAMES_ARRAY
--  from bokksu._intermediate.int__all__products__collections as collections
from clean_collections as collections
group by collections.COMPOSITE_PRODUCT_ID
)



select 
p.COMPOSITE_PRODUCT_ID,
p.composite_product_variant_id,
brand, 
--p.flavor_type, 
p.lineitem_type,
flavor,
COLLECTION_ID_ARRAY,
case
    when c.COLLECTION_NAMES_ARRAY is null
    then 'No Collection'
    else c.COLLECTION_NAMES_ARRAY
end as COLLECTION_NAMES_ARRAY
from flavor_categories as p
left join agg_collections as c on p.COMPOSITE_PRODUCT_ID = c.COMPOSITE_PRODUCT_ID

