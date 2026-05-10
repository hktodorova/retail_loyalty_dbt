-- Author : Hristina Todorova
-- Layer  : Staging
-- Model  : stg_orders
-- Desc   : Cleans and deduplicates raw order headers. Casts types, normalises
--          status/channel/currency, and removes rows with null order or customer ids.

select
    cast(order_id as bigint) as order_id,
    cast(customer_id as bigint) as customer_id,
    cast(order_date as date) as order_date,
    lower(trim(order_status)) as order_status,
    lower(trim(sales_channel)) as sales_channel,
    upper(trim(currency)) as currency
from {{ source('raw', 'orders_master') }}

where order_id is not null
  and customer_id is not null

qualify row_number() over (
    partition by order_id
    order by order_date desc
) = 1