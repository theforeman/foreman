# Ignore Dynflow tables when schema-dumping. Dynflow tables are handled automatically by Dynflow.
# Ruby dumper recognizes table names and regular expression (as string), PostgreSQL dumper only
# recognizes table names as it passes this to pg_dump via arguments.
#
ActiveRecord::SchemaDumper.ignore_tables = [
  'dynflow_actions',
  'dynflow_coordinator_records',
  'dynflow_delayed_plans',
  'dynflow_envelopes',
  'dynflow_execution_plans',
  'dynflow_output_chunks',
  'dynflow_schema_info',
  'dynflow_steps',
]
