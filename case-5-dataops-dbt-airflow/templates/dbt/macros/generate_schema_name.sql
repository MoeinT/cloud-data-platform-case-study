-- Custom schemas (staging, marts, ...) are used only in prod.
-- In dev and CI, everything goes to the target schema, so CI can never write to a prod schema.
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if target.name == 'prod' and custom_schema_name is not none -%}
        {{ custom_schema_name | trim }}
    {%- else -%}
        {{ target.schema }}
    {%- endif -%}
{%- endmacro %}
