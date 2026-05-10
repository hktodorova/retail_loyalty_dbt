-- Author : Hristina Todorova
-- Layer  : Staging
-- Model  : stg_customers
-- Desc   : Cleans raw customer records. Standardises segment to uppercase,
--          trims whitespace, and deduplicates by customer_id.

select
    cast(customer_id as bigint) as customer_id,
    trim(customer_name) as customer_name,
    upper(trim(segment)) as segment,
    trim(cast(country as varchar)) as country,
    cast(signup_date as date) as signup_date,
    cast(email as varchar) as email

from {{ source('raw', 'customers') }}
where customer_id is not null

qualify row_number() over (
    partition by customer_id
    order by signup_date desc
) = 1