-- Author : Hristina Todorova
-- Layer  : Mart
-- Model  : dim_customers
-- Desc   : Customer dimension. Exposes cleaned customer attributes for joining
--          to fact tables.

select
    customer_id,
    segment,
    country,
    signup_date

from {{ ref('stg_customers') }}