-- Author : Hristina Todorova
-- Layer  : Staging
-- Model  : stg_customer_cards
-- Desc   : Cleans raw loyalty card records. Filters out null/empty card_ids
--          and deduplicates by card_id keeping the most recent card.

select
    coalesce(upper(trim(cast(card_id as varchar))), '') as card_id,
    cast(customer_id as bigint) as customer_id,
    cast(card_created_at as timestamp) as card_created_at,
    lower(trim(card_status)) as card_status

from {{ source('raw', 'customer_cards') }}
where card_id is not null
  and trim(cast(card_id as varchar)) != ''
  and customer_id is not null

qualify row_number() over (
    partition by card_id
    order by card_created_at desc
) = 1    