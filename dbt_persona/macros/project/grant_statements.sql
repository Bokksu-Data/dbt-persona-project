--On Run Ends. Grants permissions for tables, and schemas to roles

{% macro grant_statements() %}
  {% if target.name == 'prod' %}
    -- grant usage on all schemas in database "BOKKSU" to role MODE_ROLE;
    -- grant select on all tables in database "BOKKSU" to role MODE_ROLE;
    -- grant select on all views in database "BOKKSU" to role MODE_ROLE;

    grant usage on database BOKKSU to role MODE_ROLE;
    grant usage on schema _PERSONAS to role MODE_ROLE;
    grant select on all tables in schema _PERSONAS to role MODE_ROLE;
    grant select on all views in schema _PERSONAS to role MODE_ROLE;

    grant usage on schema _PERSONAS to role HIGHTOUCH_ROLE;
    grant select on all tables in schema _PERSONAS to role HIGHTOUCH_ROLE;
    grant select on all views in schema _PERSONAS to role HIGHTOUCH_ROLE;

    grant usage on schema _PERSONAS to role INTERN_ROLE;
    grant select on all tables in schema _PERSONAS to role INTERN_ROLE;
    grant select on all views in schema _PERSONAS to role INTERN_ROLE;

    select 1; -- hooks will error if they do not have valid SQL in them, this handles that!
  {% endif %}
{% endmacro %}