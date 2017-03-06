class PxeTemplateNameValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.empty?
      template_kind = record.name.split('_').last
      tmpl = ProvisioningTemplate.find_global_default_template value, template_kind
      unless tmpl
        msg = _('is invalid. No provisioning template with name "%{name}" and kind "%{kind}" found. ') % { :name => value, :kind => template_kind }
        msg << _('Consult "Provisioning Templates" page to see what templates are available.')
        record.errors[attribute] << msg
      end
    end
  end
end
