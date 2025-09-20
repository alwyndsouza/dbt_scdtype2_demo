{% macro query_dim_customers() %}
    {% set query %}
        select 
            customer_id, 
            city, 
            date(effective_start_date) as effective_start_date, 
            date(effective_end_date) as effective_end_date, 
            active_flag 
        from {{ ref('dim_customers') }} 
        order by effective_start_date
    {% endset %}
    {% set results = run_query(query) %}
    {% do results.print_table() %}
{% endmacro %}
