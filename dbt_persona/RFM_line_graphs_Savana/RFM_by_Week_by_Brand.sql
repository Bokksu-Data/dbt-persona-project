select * from BOKKSU._PERSONAS.DIM__RFM_BY_WEEK_BY_BRAND
-- where user_id = '971ea3160cf52985be2da619839a3137' or user_id = '88f660818f75560769c7525c02d1748c' or user_id = '61b58779810bd55495402b03c615e7cd'
where date_week >= '2023-01-01'
order by date_week desc