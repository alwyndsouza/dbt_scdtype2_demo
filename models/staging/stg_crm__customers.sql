-- models/staging/stg_crm__customers.sql
select
    customer_id,
    row_id,
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
    last_modified_date,
    operation_type  -- INSERT, UPDATE, DELETE
from {{ ref('customers') }}