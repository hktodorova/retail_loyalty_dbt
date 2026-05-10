-- Author : Hristina Todorova
-- Layer  : Analytics
-- Model  : loyalty_card_summary
-- Desc   : Per-card loyalty summary showing points earned, redeemed, current
--          balance, and transaction count. Ordered by points balance descending.

select
    card_id,
    customer_id,
    card_status,
    sum(case when points_delta > 0 then points_delta else 0 end)
        as points_earned,
    sum(case when points_delta < 0 then abs(points_delta) else 0 end)
        as points_redeemed,
    sum(points_delta) as points_balance,
    count(*) as transaction_count

from {{ ref('fact_card_points_ledger') }}
group by
    card_id,
    customer_id,
    card_status
order by points_balance desc