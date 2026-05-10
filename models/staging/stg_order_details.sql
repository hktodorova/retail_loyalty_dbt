-- Author : Hristina Todorova
-- Layer  : Staging
-- Model  : stg_order_details
-- Desc   : Cleans raw order line items. Strips the ' CHF' suffix from unit_price,
--          fills missing quantities, and deduplicates exact-duplicate rows.

select
    cast(order_id as bigint) as order_id,
    cast(line_id as bigint) as line_id,
    coalesce(upper(trim(cast(product_id as varchar))), '') as product_id,
    coalesce(cast(quantity as double), 1) as quantity,
    cast(replace(trim(cast(unit_price as varchar)), ' CHF', '') as double) as unit_price,
    coalesce(cast(discount_pct as double), 0) as discount_pct

from {{ source('raw', 'order_details') }}
where order_id is not null
    and line_id is not null

qualify row_number() over (
    partition by
        order_id,
        line_id,
        product_id,
        quantity,
        unit_price,
        discount_pct
    order by order_id
) = 1