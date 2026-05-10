-- Author : Hristina Todorova
-- Layer  : Intermediate
-- Model  : int_order_amounts
-- Desc   : Calculates gross and net revenue per order by aggregating line items.
--          Applies discount logic at line level before summing.

with line_calculations as (

    select
        order_id,
        quantity,
        unit_price,
        discount_pct,
        quantity * unit_price as line_gross,
        quantity * unit_price
            * (1 - discount_pct / 100) as line_net

    from {{ ref('stg_order_details') }}

)

select
    order_id,
    sum(line_gross) as order_gross_amount,
    sum(line_net) as order_expected_amount

from line_calculations
group by order_id