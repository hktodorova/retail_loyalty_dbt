-- Author : Hristina Todorova
-- Layer  : Mart
-- Model  : dim_products
-- Desc   : Product dimension. Exposes cleaned product attributes for joining
--          to order line facts.

select
    product_id,
    product_name,
    category,
    standard_price

from {{ ref('stg_products') }}