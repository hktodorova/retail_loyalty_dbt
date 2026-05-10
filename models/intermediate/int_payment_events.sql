-- Author : Hristina Todorova
-- Layer  : Intermediate
-- Model  : int_payment_events
-- Desc   : Adds boolean payment flags and derives cash_collected_amount and
--          refund_amount from raw payment events. One row per payment event.

select
    payment_id,
    order_id,
    payment_datetime,

    payment_type,
    payment_status,
    
    payment_amount,
    card_id,
    points_used,
    
    payment_status = 'success' as is_successful_payment,
    (payment_status = 'refunded') or (payment_type = 'refund') as is_refund,
    payment_status = 'pending' as is_pending,
    payment_status = 'failed' as is_failed,
    payment_type in ('points', 'loyalty_card') as is_points_payment,
    payment_type = 'installment' as is_installment_payment,
    case
        when payment_status = 'success' and payment_amount > 0 then payment_amount
        else 0
    end as cash_collected_amount,
    case
        when payment_status = 'refunded' or payment_type = 'refund' then abs(payment_amount)
        else 0
    end as refund_amount

from {{ ref('stg_payments') }}