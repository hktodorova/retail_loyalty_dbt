-- Author : Hristina Todorova
-- Layer  : Intermediate
-- Model  : int_computed_earn_events
-- Desc   : Derives loyalty earn events from valid revenue orders using points
--          threshold rules. Joins active cards to eligible orders and looks up
--          the correct points_awarded band.

with active_cards as (

    select
        card_id,
        customer_id,
        card_status

    from {{ ref('stg_customer_cards') }}

    where card_status = 'active'

),

eligible_orders as (

    select
        fo.order_id,
        fo.customer_id,
        fo.order_date,
        fo.order_expected_amount,
        ac.card_id

    from {{ ref('int_order_revenue_status') }} fo

    inner join active_cards ac
        on fo.customer_id = ac.customer_id

    where fo.is_valid_revenue

),

computed_earn as (

    select
        eo.order_id,
        eo.card_id,
        eo.order_date as event_datetime,
        'earn' as event_type,
        'computed_threshold' as ledger_source,
        pt.points_awarded as points_delta

    from eligible_orders eo

    inner join {{ ref('stg_points_thresholds') }} pt
        on eo.order_expected_amount >= pt.min_amount
        and (
            pt.max_amount is null
            or eo.order_expected_amount <= pt.max_amount
        )

),

raw_earn_keys as (

    select distinct
        card_id,
        order_id

    from {{ ref('stg_card_points_ledger') }}

    where event_type = 'earn'
      and order_id is not null

)

select
    ce.order_id,
    ce.card_id,
    ce.event_datetime,
    ce.event_type,
    ce.points_delta,
    ce.ledger_source

from computed_earn ce

left join raw_earn_keys rek
    on ce.card_id = rek.card_id
    and ce.order_id = rek.order_id

where rek.card_id is null