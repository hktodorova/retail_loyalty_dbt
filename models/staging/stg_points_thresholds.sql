-- Author : Hristina Todorova
-- Layer  : Staging
-- Model  : stg_points_thresholds
-- Desc   : Cleans the points threshold lookup table. Filters out rows with
--          null threshold_id, min_amount, or points_awarded.

select
    cast(threshold_id as bigint) as threshold_id,
    cast(min_amount as double) as min_amount,
    cast(max_amount as double) as max_amount,
    coalesce(cast(points_awarded as bigint), 0) as points_awarded

from {{ source('raw', 'points_thresholds') }}
where threshold_id is not null
    and min_amount is not null
    and points_awarded is not null