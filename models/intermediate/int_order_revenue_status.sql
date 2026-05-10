-- Author : Hristina Todorova
-- Layer  : Intermediate
-- Model  : int_order_revenue_status
-- Desc   : Combines order headers, line amounts, and payment aggregates into a
--          single pre-mart model. Derives payment status flags and valid revenue
--          classification used by the fact layer.

select
    order_id,
    customer_id,
    order_date,
    order_status,
    sales_channel,
    currency,

    coalesce(points_used, 0) as points_used,
    coalesce(payment_event_count, 0) as payment_event_count,
    latest_payment_status,

    coalesce(order_expected_amount, 0) as order_expected_amount,
    coalesce(total_cash_collected_amount, 0) as total_cash_collected_amount,
    coalesce(total_refund_amount, 0) as total_refund_amount,
    coalesce(net_collected_amount, 0) as net_collected_amount,

    coalesce(net_collected_amount, 0) >= coalesce(order_expected_amount, 0)
        and coalesce(order_expected_amount, 0) > 0
        as is_fully_paid,

    coalesce(net_collected_amount, 0) > 0
        and coalesce(net_collected_amount, 0) < coalesce(order_expected_amount, 0)
        as is_partially_paid,

    coalesce(net_collected_amount, 0) > coalesce(order_expected_amount, 0)
        and coalesce(order_expected_amount, 0) > 0
        as is_overpaid,

    order_status = 'paid'
        and coalesce(has_successful_payment, false)
        and coalesce(net_collected_amount, 0) > 0
        as is_valid_revenue,
    (coalesce(payment_event_count, 0) > 0) as has_any_payment,
    coalesce(installment_event_count, 0) as installment_event_count,
    coalesce(has_successful_payment, false) as has_successful_payment,
    coalesce(has_pending_payment, false) as has_pending_payment

from {{ ref('stg_orders') }}
left join {{ ref('int_order_amounts') }} using (order_id)
left join {{ ref('int_payment_aggregates') }} using (order_id)
left join {{ ref('int_latest_payment_status') }} using (order_id)