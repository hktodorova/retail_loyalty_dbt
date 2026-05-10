-- Author : Hristina Todorova
-- Layer  : Analytics
-- Model  : revenue_by_day
-- Desc   : Daily revenue breakdown for valid revenue orders. Includes expected,
--          collected, refunded, and net collected revenue per day.

select
    order_date,
    count(order_id) as order_count,
    sum(order_expected_amount) as total_expected_revenue,
    sum(total_cash_collected_amount) as total_cash_collected,
    sum(total_refund_amount) as total_refunds,
    sum(net_collected_amount) as net_collected_revenue

from {{ ref('fact_orders') }}
where is_valid_revenue
group by order_date
order by order_date