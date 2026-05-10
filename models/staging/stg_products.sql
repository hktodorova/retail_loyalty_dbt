-- Author : Hristina Todorova
-- Layer  : Staging
-- Model  : stg_products
-- Desc   : Cleans raw product records. Standardises category to uppercase,
--          fills null prices with 0, and deduplicates by product_id.

select
    coalesce(upper(trim(cast(product_id as varchar))), '') as product_id,
    trim(cast(product_name as varchar)) as product_name,
    upper(trim(cast(category as varchar))) as category,
    coalesce(cast(standard_price as double), 0) as standard_price,
    coalesce(cast(is_active as boolean), false) as is_active

from {{ source('raw', 'products') }}
where product_id is not null
  and trim(cast(product_id as varchar)) != ''

qualify row_number() over (
    partition by product_id
    order by standard_price desc
) = 1