# Provisioning templates
organizations = Organization.unscoped.all
locations = Location.unscoped.all
ProvisioningTemplate.without_auditing do
  ProvisioningTemplatesList.seeded_templates.each do |input|
    contents = File.read(File.join("#{Rails.root}/app/views/unattended/provisioning_templates", input[:source]))

    if (t = ProvisioningTemplate.unscoped.find_by_name(input[:name])) && !SeedHelper.audit_modified?(ProvisioningTemplate, input[:name])
      if t.template != contents || t.vendor != 'Foreman'
        t.template = contents
        t.locked = true
        t.vendor = 'Foreman'
        t.ignore_locking do
          t.ignore_default do
            raise "Unable to update template #{t.name}: #{format_errors t}" unless t.save
          end
        end
      end
    else
      next if SeedHelper.audit_modified? ProvisioningTemplate, input[:name]
      t = ProvisioningTemplate.create({
                                        :template => contents,
                                        :locked => true,
                                        :default => true,
                                        :name => input[:name],
                                        :template_kind => input[:template_kind],
                                        :snippet => input[:snippet] || false,
                                        :vendor => 'Foreman'
                                      })

      t.organizations = organizations if SETTINGS[:organizations_enabled]
      t.locations = locations if SETTINGS[:locations_enabled]
      raise "Unable to create template #{t.name}: #{format_errors t}" if t.nil? || t.errors.any?
    end
  end
end
