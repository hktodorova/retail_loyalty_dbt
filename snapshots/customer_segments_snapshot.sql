{% snapshot customer_segments_snapshot %}

{{
    config(
        target_schema='snapshots',
        unique_key='customer_id',
        strategy='check',
        check_cols=['segment']
    )
}}

select
    customer_id,
    customer_name,
    segment,
    country,
    signup_date

from {{ ref('stg_customers') }}

{% endsnapshot %}
