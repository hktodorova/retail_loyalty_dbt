select
    order_id,
    order_status,
    has_successful_payment

from {{ ref('fact_orders') }}

where order_status = 'paid'
  and has_successful_payment = false