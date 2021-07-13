# Ignore Dynflow tables when schema-dumping. Dynflow tables are handled automatically by Dynflow.
ActiveRecord::SchemaDumper.ignore_tables << '^dynflow_*'
