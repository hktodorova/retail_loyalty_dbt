-- Author : Hristina Todorova
-- Layer  : Analytics
-- Model  : kpi_summary
-- Desc   : Single-row KPI aggregate across all orders and loyalty activity.
--          Powers the retail KPI dashboard exposure.

with order_kpis as (

    select
        count(*) as total_orders,

        sum(is_valid_revenue::integer) as valid_revenue_orders,

        case
            when count(*) = 0 then 0
            else sum(is_valid_revenue::integer) * 1.0 / count(*)
        end as conversion_rate,

        sum(case when is_valid_revenue then order_expected_amount else 0 end)
            as total_expected_revenue,

        sum(case when is_valid_revenue then total_cash_collected_amount else 0 end)
            as total_cash_collected,

        sum(case when is_valid_revenue then total_refund_amount else 0 end)
            as total_refunds,

        sum(case when is_valid_revenue then net_collected_amount else 0 end)
            as net_collected_revenue,

        case
            when sum(is_valid_revenue::integer) = 0 then 0
            else
                sum(case when is_valid_revenue then net_collected_amount else 0 end)
                / sum(is_valid_revenue::integer)
        end as avg_order_value,

        sum(is_partially_paid::integer) as partial_payment_orders,

        sum(is_overpaid::integer) as overpaid_orders,

        sum(
            case
                when order_status = 'cancelled'
                    and has_any_payment
                then 1
                else 0
            end
        ) as cancelled_orders_with_payment,

        sum(
            case
                when points_used > 0
                    and is_valid_revenue
                then 1
                else 0
            end
        ) as orders_paid_with_points

    from {{ ref('fact_orders') }}

),

loyalty_kpis as (

    select
        count(distinct case when card_status = 'active' then card_id end)
            as active_cards,

        sum(case when points_delta > 0 then points_delta else 0 end)
            as points_earned,

        sum(case when points_delta < 0 then abs(points_delta) else 0 end)
            as points_redeemed

    from {{ ref('fact_card_points_ledger') }}

),

points_balance as (

    select
        card_id,
        sum(points_delta) as points_balance

    from {{ ref('fact_card_points_ledger') }}

    group by card_id

),

points_liability as (

    select
        sum(
            case
                when points_balance > 0 then points_balance
                else 0
            end
        ) as points_liability

    from points_balance

),

active_card_customers as (

    select distinct
        customer_id

    from {{ ref('fact_card_points_ledger') }}

    where card_status = 'active'
      and customer_id is not null

),

loyalty_revenue as (

    select
        sum(
            case
                when fo.is_valid_revenue
                    and acc.customer_id is not null
                then fo.net_collected_amount
                else 0
            end
        ) as loyalty_valid_revenue,

        sum(
            case
                when fo.is_valid_revenue
                then fo.net_collected_amount
                else 0
            end
        ) as total_valid_revenue

    from {{ ref('fact_orders') }} fo

    left join active_card_customers acc
        on fo.customer_id = acc.customer_id

)

select
    ok.total_orders,
    ok.valid_revenue_orders,
    ok.conversion_rate,
    ok.total_expected_revenue,
    ok.total_cash_collected,
    ok.total_refunds,
    ok.net_collected_revenue,
    ok.avg_order_value,
    ok.partial_payment_orders,
    ok.overpaid_orders,
    ok.cancelled_orders_with_payment,

    lk.active_cards,
    lk.points_earned,
    lk.points_redeemed,
    pl.points_liability,

    ok.orders_paid_with_points,

    case
        when lr.total_valid_revenue = 0 then 0
        else lr.loyalty_valid_revenue / lr.total_valid_revenue
    end as loyalty_revenue_share

from order_kpis ok
cross join loyalty_kpis lk
cross join points_liability pl
cross join loyalty_revenue lr