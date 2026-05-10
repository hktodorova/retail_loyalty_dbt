-- Author : Hristina Todorova
-- Layer  : Intermediate
-- Model  : int_latest_payment_status
-- Desc   : Returns the most recent payment status per order using a window function
--          ordered by payment_datetime and payment_id.

select
    order_id,
    payment_status as latest_payment_status

from {{ ref('int_payment_events') }}

qualify row_number() over (
    partition by order_id
    order by payment_datetime desc, payment_id desc
) = 1