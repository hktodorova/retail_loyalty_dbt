-- Author : Hristina Todorova
-- Layer  : Mart
-- Model  : fact_orders
-- Desc   : One row per order. Publishes the full int_order_revenue_status model
--          as the primary orders fact table.

select
    *

from {{ ref('int_order_revenue_status') }}
