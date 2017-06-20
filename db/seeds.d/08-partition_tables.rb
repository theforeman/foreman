# Partition tables
organizations = Organization.unscoped.all
locations = Location.unscoped.all

Ptable.without_auditing do
  PartitionTablesList.seeded_templates.each do |input|
    contents = File.read(File.join("#{Rails.root}/app/views/unattended/partition_tables_templates", input[:source]))

    if (p = Ptable.unscoped.find_by_name(input[:name])) && !SeedHelper.audit_modified?(Ptable, input[:name])
      if p.layout != contents
        p.layout = contents
        p.ignore_locking do
          p.ignore_default do
            raise "Unable to update partition table #{p.name}: #{format_errors p}" unless p.save
          end
        end
      end
    else
      next if SeedHelper.audit_modified? Ptable, input[:name]
      p = Ptable.create({
                          :layout => contents,
                          :default => true,
                          :name => input[:name],
                          :os_family => input[:os_family]
                        })

      if p.default?
        p.organizations = organizations if SETTINGS[:organizations_enabled]
        p.locations = locations if SETTINGS[:locations_enabled]
      end
      raise "Unable to create partition table: #{format_errors p}" if p.nil? || p.errors.any?
    end
  end
end
