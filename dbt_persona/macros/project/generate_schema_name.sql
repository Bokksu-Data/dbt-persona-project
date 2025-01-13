{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}

        {{ default_schema }}

    {%- elif target.name == 'dev' -%}

        test_{{ custom_schema_name | trim }}
    
    {%- elif target.name == 'dev_ayesha' -%}

        test_paul_{{ custom_schema_name | trim }}
    
    {%- elif target.name == 'dev_karina' -%}

        test_savana_{{ custom_schema_name | trim }}
    
    {%- elif target.name == 'dev_sabirah' -%}

        test_vanessa_{{ custom_schema_name | trim }}
        
    {%- elif target.name == 'dev_mayesha' -%}

        test_fasih_{{ custom_schema_name | trim }}

    {%- elif target.name == 'dev_sanskriti' -%}

        test_saad_{{ custom_schema_name | trim }}
    
    {%- elif target.name == 'dev_savana' -%}

        test_saad_{{ custom_schema_name | trim }}
    
    
    {%- else -%}

        _{{ custom_schema_name | trim }}

    {%- endif -%}

{%- endmacro %}