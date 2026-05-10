with card_balances as (

    select
        card_id,
        sum(points_delta) as points_balance

    from {{ ref('fact_card_points_ledger') }}

    group by card_id

)

select
    card_id,
    points_balance

from card_balances

where points_balance < 0