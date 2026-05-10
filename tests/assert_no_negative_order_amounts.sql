select
    order_id,
    order_expected_amount

from {{ ref('fact_orders') }}

where order_expected_amount < 0
