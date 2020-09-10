# Provisioning templates
ProvisioningTemplate.without_auditing do
  TemplateKind.default_template_labels.keys.map(&:to_sym).each do |type|
    kind ||= TemplateKind.unscoped.find_or_create_by(name: type)
    kind.description = TemplateKind.default_template_descriptions[kind.name]
    kind.save!
  end

  SeedHelper.import_templates(SeedHelper.provisioning_templates)
end
