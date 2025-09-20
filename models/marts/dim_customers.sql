{{
    config(
        materialized='incremental',
        unique_key='scd_id',
        incremental_strategy='delete+insert'
    )
}}

with source_rows as (
    select
        *
    from {{ ref('int_crm__customers_scd') }}
),

{% if is_incremental() %}

destination_rows as (
    select
        *
    from {{ this }}
    where active_flag = 'Y'
),

updates as (
    select
        d.scd_id as old_scd_id,
        min(s.effective_start_date) as effective_start_date
    from source_rows s
    join destination_rows d
    on s.customer_id = d.customer_id
    where s.scd_id <> d.scd_id
    group by d.scd_id
),

expired as (
    select
        d.customer_id,
        d.customer_name,
        d.first_name,
        d.last_name,
        d.email_address,
        d.phone_number,
        d.annual_income,
        d.city,
        d.marketing_consent_email,
        d.marketing_consent_sms,
        d.contact_preference,
        d.effective_start_date,
        u.effective_start_date as effective_end_date,
        'N' as active_flag,
        d.scd_id
    from destination_rows d
    join updates u
    on d.scd_id = u.old_scd_id
),
{% endif %}

new_records as (
    select
        customer_id,
        customer_name,
        first_name,
        last_name,
        email_address,
        phone_number,
        annual_income,
        city,
        marketing_consent_email,
        marketing_consent_sms,
        contact_preference,
        effective_start_date,
        coalesce(
            lead(effective_start_date, 1) over (
                partition by customer_id
                order by effective_start_date
            ),
            '9999-12-31'::timestamp
        ) as effective_end_date,
        case
            when lead(effective_start_date, 1) over (
                partition by customer_id
                order by effective_start_date
            ) is null then 'Y'
            else 'N'
        end as active_flag,
        scd_id
    from source_rows
)

select * from new_records

{% if is_incremental() %}
union all
select * from expired
{% endif %}
