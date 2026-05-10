-- Author : Hristina Todorova
-- Layer  : Staging
-- Model  : stg_card_points_ledger
-- Desc   : Cleans raw loyalty points ledger events. Casts types, normalises
--          event_type to lowercase, and fills null points_delta with 0.

select
    cast(ledger_id as varchar) as ledger_id,
    coalesce(upper(trim(cast(card_id as varchar))), '') as card_id,
    cast(order_id as bigint) as order_id,
    cast(event_datetime as timestamp) as event_datetime,
    lower(trim(event_type)) as event_type,
    coalesce(cast(points_delta as double), 0) as points_delta

from {{ source('raw', 'card_points_ledger') }}
where ledger_id is not null
  and trim(cast(card_id as varchar)) != ''