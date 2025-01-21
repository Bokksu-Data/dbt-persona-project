{{ config(materialized='table') }}

WITH 

clean_collections as 
(
select 
    TRIM(
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(u.collection_title, '(QUIZ)', ''),'JANUARY', ''),'FEBRUARY', ''),'MARCH', ''),'APRIL', ''),'MAY', ''),'JUNE', ''),'JULY', ''),'AUGUST', ''),'SEPTEMBER', ''),'OCTOBER', ''),'NOVEMBER', ''),'DECEMBER', ''),'+', ''),'.', ''),':', ''),'0', ''),'1', ''),'2', ''),'3', ''),'4', ''),'5', ''),'6', ''),'7', ''),'8', ''),'9', '')
) as collection_title
from bokksu._intermediate.int__all__products__collections as collections
),

flavor_categories AS (
SELECT 
p.composite_product_variant_id, 
p.flavor_type, 
p.lineitem_type,
p.flavor_type as flavor,
p.pl_type_refact
FROM BOKKSU._core.dim__all__products as p
WHERE p.flavor_type IS NOT NULL
)

select * from flavor_categories


-- select
--     collections.COMPOSITE_PRODUCT_ID as COLLECTION_COMPOSITE_PRODUCT_ID,
--     LISTAGG(collections.COMPOSITE_COLLECTION_ID, ', ') as COLLECTION_ID_ARRAY,
--     LISTAGG(collections.COLLECTION_TITLE, ', ') as COLLECTION_NAMES_ARRAY
-- --  from bokksu._intermediate.int__all__products__collections as collections
-- from clean_collections as collections
-- group by collections.COMPOSITE_PRODUCT_ID