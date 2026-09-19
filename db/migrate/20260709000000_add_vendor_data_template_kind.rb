class AddVendorDataTemplateKind < ActiveRecord::Migration[7.0]
  def up
    TemplateKind.unscoped.find_or_create_by(name: 'vendor_data') do |kind|
      kind.description = TemplateKind.default_template_descriptions['vendor_data']
    end
  end

  def down
    kind = TemplateKind.unscoped.find_by(name: 'vendor_data')
    return unless kind

    kind.os_default_templates.destroy_all
    kind.provisioning_templates.destroy_all
    kind.destroy
  end
end
