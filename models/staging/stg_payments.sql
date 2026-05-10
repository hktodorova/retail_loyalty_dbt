-- Author : Hristina Todorova
-- Layer  : Staging
-- Model  : stg_payments
-- Desc   : Cleans raw payment events. Normalises payment_type and payment_status
--          to lowercase, fills null amounts with 0, and deduplicates by payment_id.

select
    cast(payment_id as bigint) as payment_id,
    cast(order_id as bigint) as order_id,
    cast(payment_datetime as timestamp) as payment_datetime,

    lower(trim(payment_type)) as payment_type,
    lower(trim(payment_status)) as payment_status,

    coalesce(cast(payment_amount as double), 0) as payment_amount,
    coalesce(cast(points_used as double), 0) as points_used,

    upper(trim(card_id)) as card_id

from {{ source('raw', 'payments') }}
where payment_id is not null
  and order_id is not null

qualify row_number() over (
    partition by payment_id
    order by payment_datetime desc
) = 1