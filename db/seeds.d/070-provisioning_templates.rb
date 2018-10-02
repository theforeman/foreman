# Provisioning templates
ProvisioningTemplate.without_auditing do

  TemplateKind.default_template_labels.keys.each do |type|
    kind = TemplateKind.unscoped.find_by_name(type)
    kind ||= TemplateKind.unscoped.create(:name => type)
    raise "Unable to create template kind: #{SeedHelper.format_errors(kind)}" if kind.nil? || kind.errors.any?
  end

  SeedHelper.import_templates(SeedHelper.provisioning_templates)
end
