-- Author : Hristina Todorova
-- Layer  : Mart
-- Model  : fact_payments
-- Desc   : One row per payment event. Incremental model keyed on payment_id.
--          Includes all payment flags and derived cash/refund amounts.

{{
    config(
        materialized='incremental',
        unique_key='payment_id'
    )
}}

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
    payment_status = 'refunded' or payment_type = 'refund' as is_refund,
    payment_status = 'pending' as is_pending,
    payment_status = 'failed' as is_failed,
    payment_type in ('points', 'loyalty_card') as is_points_payment,
    payment_type = 'installment' as is_installment_payment,

    case
        when payment_status = 'success'
            and payment_amount > 0
        then payment_amount
        else 0
    end as cash_collected_amount,

    case
        when payment_status = 'refunded'
            or payment_type = 'refund'
        then abs(payment_amount)
        else 0
    end as refund_amount

from {{ ref('stg_payments') }}

{% if is_incremental() %}

where payment_datetime > (
    select coalesce(max(payment_datetime), timestamp '1900-01-01')
    from {{ this }}
)

{% endif %}