-- Called at the end of every CI run: dbt run-operation drop_ci_schema --target ci
{% macro drop_ci_schema() %}
    {% if target.name == 'ci' %}
        {% do adapter.drop_schema(api.Relation.create(database=target.database, schema=target.schema)) %}
        {{ log("Dropped " ~ target.schema, info=True) }}
    {% endif %}
{% endmacro %}
