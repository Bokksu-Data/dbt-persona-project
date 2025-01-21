-- depends_on: {{ ref('int__rfm_by_week_by_brand') }}
{{create_dim_rfm('int__rfm_by_week_by_brand')}}