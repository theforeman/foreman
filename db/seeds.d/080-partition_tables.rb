# Partition tables
Ptable.without_auditing do
  SeedHelper.import_templates(SeedHelper.partition_tables_templates)
end
