class PxeTemplateNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless exempt_templates.include? value
      template_kind = record.name.split('_').last
      tmpl = ProvisioningTemplate.find_global_default_template value, template_kind
      unless tmpl
        msg = _('is invalid. No provisioning template with name "%{name}" and kind "%{kind}" found. ') % { :name => value, :kind => template_kind }
        msg << _('Consult "Provisioning Templates" page to see what templates are available.')
        record.errors[attribute] << msg
      end
    end
  end

  def local_boot_templates
    TemplateKind::PXE.map { |kind| Foreman::Provision.local_boot_default_name kind }
  end

  def global_default_templates
    TemplateKind::PXE.map { |kind| Foreman::Provision.global_default_name kind }
  end

  def exempt_templates
    global_default_templates + local_boot_templates
  end
end
