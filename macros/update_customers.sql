{% macro update_customers() %}
    {% set sql %}
        truncate table {{ source('crm', 'customers') }};
        insert into {{ source('crm', 'customers') }} select * from {{ source('crm', 'customers_delta') }};
    {% endset %}
    {% do run_query(sql) %}
{% endmacro %}
