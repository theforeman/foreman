class RenameConfigTemplateToProvisioningTemplate < ActiveRecord::Migration
  PERMISSIONS = %w(view_templates create_templates edit_templates destroy_templates deploy_templates lock_templates)

  def up
    old_name = 'ConfigTemplate'
    new_name = 'ProvisioningTemplate'

    Template.update_all "type = '#{new_name}'", "type = '#{old_name}'"
    Audit.update_all "auditable_type = '#{new_name}'", "auditable_type = '#{old_name}'"
    TaxableTaxonomy.update_all "taxable_type = '#{new_name}'", "taxable_type = '#{old_name}'"
    Permission.update_all "resource_type = '#{new_name}'", "resource_type = '#{old_name}'"

    PERMISSIONS.each do |from|
      to = from.sub('templates', 'provisioning_templates')
      say "renaming permission #{from} to #{to}"
      Permission.update_all "name = '#{to}'", "name = '#{from}'"
    end

    if foreign_keys('os_default_templates').find { |f| f.options[:name] == 'os_default_templates_config_template_id_fk' }.present?
      remove_foreign_key "os_default_templates", :name => "os_default_templates_config_template_id_fk"
    end
    if foreign_keys('template_combinations').find { |f| f.options[:name] == 'template_combinations_config_template_id_fk' }.present?
      remove_foreign_key "template_combinations", :name => "template_combinations_config_template_id_fk"
    end
    if foreign_keys('config_templates_operatingsystems').find { |f| f.options[:name] == 'config_templates_operatingsystems_config_template_id_fk' }.present?
      remove_foreign_key "config_templates_operatingsystems", :name => "config_templates_operatingsystems_config_template_id_fk"
    end

    rename_column :template_combinations, :config_template_id, :provisioning_template_id
    rename_column :os_default_templates, :config_template_id, :provisioning_template_id

    rename_table :config_templates_operatingsystems, :operatingsystems_provisioning_templates
    rename_column :operatingsystems_provisioning_templates, :config_template_id, :provisioning_template_id

    add_foreign_key "os_default_templates", "templates", :name => "os_default_templates_provisioning_template_id_fk", :column => 'provisioning_template_id'
    add_foreign_key "template_combinations", "templates", :name => "template_combinations_provisioning_template_id_fk", :column => 'provisioning_template_id'
    # name of FK was to long for MySQL, so it does not follow naming convention
    add_foreign_key "operatingsystems_provisioning_templates", "templates", :name => "os_provisioning_template_id_fk", :column => 'provisioning_template_id'
  end

  def down
    remove_foreign_key "os_default_templates", :name => "os_default_templates_provisioning_template_id_fk"
    remove_foreign_key "template_combinations", :name => "template_combinations_provisioning_template_id_fk"
    remove_foreign_key "operatingsystems_provisioning_templates", :name => "os_provisioning_template_id_fk"

    rename_column :template_combinations, :provisioning_template_id, :config_template_id
    rename_column :os_default_templates, :provisioning_template_id, :config_template_id

    rename_column :operatingsystems_provisioning_templates, :provisioning_template_id, :config_template_id
    rename_table :operatingsystems_provisioning_templates, :config_templates_operatingsystems

    add_foreign_key "os_default_templates", "config_templates", :name => "os_default_templates_config_template_id_fk"
    add_foreign_key "template_combinations", "config_templates", :name => "template_combinations_config_template_id_fk"
    add_foreign_key "config_templates_operatingsystems", "config_templates", :name => "config_templates_operatingsystems_config_template_id_fk"

    PERMISSIONS.each do |to|
      from = to.sub('provisioning_templates', 'templates')
      say "renaming permission #{from} to #{to}"
      Permission.update_all "name = '#{to}'", "name = '#{from}'"
    end

    old_name = 'ConfigTemplate'
    new_name = 'ProvisioningTemplate'

    Template.update_all "type = '#{old_name}'", "type = '#{new_name}'"
    Audit.update_all "auditable_type = '#{old_name}'", "auditable_type = '#{new_name}'"
    TaxableTaxonomy.update_all "taxable_type = '#{old_name}'", "taxable_type = '#{new_name}'"
    Permission.update_all "resource_type = '#{old_name}'", "resource_type = '#{new_name}'"
  end
end
