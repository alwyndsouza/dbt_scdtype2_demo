-- models/intermediate/int_crm__customers_scd.sql
select
    *,
    {{ dbt_utils.generate_surrogate_key([
        'customer_id',
        'customer_name',
        'email_address',
        'phone_number',
        'city',
        'marketing_consent_email'
    ]) }} as scd_id,
    coalesce(last_modified_date, current_timestamp) as effective_start_date
from {{ ref('stg_crm__customers') }}
