with
product as (select 
*,
case 

when product_price <= 5
THEN '$0-$5'

when product_price <= 10
THEN '$5-$10'

when product_price <= 15
THEN '$10-$15'

when product_price <= 20
THEN '$15-$20'

when product_price <= 40
THEN '$20-$40'

when product_price <= 60
THEN '$40-$60'

when product_price <= 80
THEN '$60-$80'

when product_price <= 100
THEN '$80-$100'

when product_price <= 200
THEN '$100-$200'

when product_price <= 300
THEN '$200-$300'

when product_price <= 400
THEN '$300-$400'

when product_price <= 600
THEN '$400-$600'

when product_price <= 1000
THEN '$600-$1000'

when product_price > 1000
then '$1000'

end as PRICE_BIN

from BOKKSU._PERSONAS.GROUPED_BY_COLLECTION_HOLIDAY
),

get_sum as (
select 
COMPOSITE_PRODUCT_VARIANT_ID, 
sum(TOTAL_UNITS_SOLD) as summed_products

from product
group by 1
)


select *,


CASE
when summed_products <= 50
THEN '0-50'

when summed_products <= 100
THEN '50-100'

when summed_products <= 300
THEN '100-300'

when summed_products <= 500
THEN '300-500'

when summed_products <= 700
THEN '500-700'

when summed_products <= 1000
THEN '700-1000'

when summed_products <= 2000
THEN '1000-2000'

when summed_products <= 4000
THEN '2000-4000'

when summed_products <= 6000
THEN '4000-6000'

when summed_products <= 8000
THEN '6000-8000'

when summed_products <= 10000
THEN '8000-10000'

when summed_products <= 14000
THEN '10000-14000'

when summed_products > 14000
THEN '14000+'

end as UNITS_BIN

from product left join get_sum on get_sum.composite_product_variant_id = product.COMPOSITE_PRODUCT_VARIANT_ID
with
product as (select 
*,
case 

when product_price <= 5
THEN '$0-$5'

when product_price <= 10
THEN '$5-$10'

when product_price <= 15
THEN '$10-$15'

when product_price <= 20
THEN '$15-$20'

when product_price <= 40
THEN '$20-$40'

when product_price <= 60
THEN '$40-$60'

when product_price <= 80
THEN '$60-$80'

when product_price <= 100
THEN '$80-$100'

when product_price <= 200
THEN '$100-$200'

when product_price <= 300
THEN '$200-$300'

when product_price <= 400
THEN '$300-$400'

when product_price <= 600
THEN '$400-$600'

when product_price <= 1000
THEN '$600-$1000'

when product_price > 1000
then '$1000'

end as PRICE_BIN

from BOKKSU._PERSONAS.GROUPED_BY_COLLECTION_HOLIDAY
),

get_sum as (
select 
COMPOSITE_PRODUCT_VARIANT_ID, 
sum(TOTAL_UNITS_SOLD) as summed_products

from product
group by 1
)


select *,


CASE
when summed_products <= 50
THEN '0-50'

when summed_products <= 100
THEN '50-100'

when summed_products <= 300
THEN '100-300'

when summed_products <= 500
THEN '300-500'

when summed_products <= 700
THEN '500-700'

when summed_products <= 1000
THEN '700-1000'

when summed_products <= 2000
THEN '1000-2000'

when summed_products <= 4000
THEN '2000-4000'

when summed_products <= 6000
THEN '4000-6000'

when summed_products <= 8000
THEN '6000-8000'

when summed_products <= 10000
THEN '8000-10000'

when summed_products <= 14000
THEN '10000-14000'

when summed_products > 14000
THEN '14000+'

end as UNITS_BIN

from product left join get_sum on get_sum.composite_product_variant_id = product.COMPOSITE_PRODUCT_VARIANT_ID