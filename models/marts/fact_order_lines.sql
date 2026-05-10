-- Author : Hristina Todorova
-- Layer  : Mart
-- Model  : fact_order_lines
-- Desc   : One row per order line. Calculates gross and net amounts and enriches
--          each line with product category from dim_products.

select
    od.order_id,
    od.line_id,
    od.product_id,

    od.quantity,
    od.unit_price,
    od.discount_pct,

    od.quantity * od.unit_price as line_gross,
    od.quantity * od.unit_price * (1 - od.discount_pct / 100) as line_net,
    p.product_id is not null as has_valid_product,
    p.category as product_category

from {{ ref('stg_order_details') }} od

left join {{ ref('dim_products') }} p
    on od.product_id = p.product_id