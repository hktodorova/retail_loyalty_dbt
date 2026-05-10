-- Author : Hristina Todorova
-- Layer  : Mart
-- Model  : fact_card_points_ledger
-- Desc   : Combined loyalty points ledger. Merges raw ledger events with computed
--          earn events. Each row is a single point transaction for a loyalty card.

with raw_ledger as (

    select
        order_id,
        card_id,
        event_datetime,
        event_type,
        points_delta,
        'raw' as ledger_source

    from {{ ref('stg_card_points_ledger') }}

),

computed_earn as (

    select
        order_id,
        card_id,
        event_datetime,
        event_type,
        points_delta,
        ledger_source

    from {{ ref('int_computed_earn_events') }}

),

combined_ledger as (

    select *
    from raw_ledger

    union all

    select *
    from computed_earn

),

card_metadata as (

    select
        card_id,
        customer_id,
        card_status

    from {{ ref('stg_customer_cards') }}

)

select
    cl.order_id,
    cl.card_id,
    cm.customer_id,
    cm.card_status,
    cl.event_datetime,
    cl.event_type,
    cl.points_delta,
    cl.ledger_source,

    cm.customer_id is not null as is_valid_card

from combined_ledger cl

left join card_metadata cm
    on cl.card_id = cm.card_id