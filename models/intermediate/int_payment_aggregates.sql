-- Author : Hristina Todorova
-- Layer  : Intermediate
-- Model  : int_payment_aggregates
-- Desc   : Aggregates payment events to one row per order. Sums cash collected,
--          refunds, and points used. Derives net_collected_amount and counts events.

select
    order_id,
    sum(cash_collected_amount) as total_cash_collected_amount,
    sum(refund_amount) as total_refund_amount,
    sum(cash_collected_amount) - sum(refund_amount) as net_collected_amount,
    sum(points_used) as points_used,
    count(payment_id) as payment_event_count,
    sum(is_installment_payment::integer) as installment_event_count,
    bool_or(is_successful_payment)
        as has_successful_payment,
    bool_or(is_pending)
        as has_pending_payment    

from {{ ref('int_payment_events') }}
group by order_id