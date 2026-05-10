-- Author : Hristina Todorova
-- Layer  : Analytics
-- Model  : revenue_by_customer_segment
-- Desc   : Revenue breakdown by customer segment. Joins fact_orders to
--          dim_customers and groups by segment, ordered by net revenue.

select
    coalesce(c.segment, 'UNKNOWN') as customer_segment,
    count(fo.order_id) as order_count,
    sum(fo.order_expected_amount) as total_expected_revenue,
    sum(fo.net_collected_amount) as net_collected_revenue,
    avg(fo.net_collected_amount) as avg_order_value

from {{ ref('fact_orders') }} fo
left join {{ ref('dim_customers') }} c
    on fo.customer_id = c.customer_id
where fo.is_valid_revenue
group by coalesce(c.segment, 'UNKNOWN')
order by net_collected_revenue desc