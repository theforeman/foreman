class RenameConfigTemplateToProvisioningTemplate < ActiveRecord::Migration[4.2]
  def up
    %w(os_default_templates template_combinations config_templates_operatingsystems).each do |source_table|
      if foreign_key_exists?(source_table, :name => "#{source_table}_config_template_id_fk")
        remove_foreign_key source_table, :name => "#{source_table}_config_template_id_fk"
      end
    end

    rename_column :template_combinations, :config_template_id, :provisioning_template_id
    rename_column :os_default_templates, :config_template_id, :provisioning_template_id

    rename_table :config_templates_operatingsystems, :operatingsystems_provisioning_templates
    rename_column :operatingsystems_provisioning_templates, :config_template_id, :provisioning_template_id

    add_foreign_key 'os_default_templates', 'templates', :name => 'os_default_templates_provisioning_template_id_fk', :column => 'provisioning_template_id'
    add_foreign_key 'template_combinations', 'templates', :name => 'template_combinations_provisioning_template_id_fk', :column => 'provisioning_template_id'
    # name of FK was to long for MySQL, so it does not follow naming convention
    add_foreign_key 'operatingsystems_provisioning_templates', 'templates', :name => 'os_provisioning_template_id_fk', :column => 'provisioning_template_id'
  end

  def down
    remove_foreign_key 'os_default_templates', :name => 'os_default_templates_provisioning_template_id_fk'
    remove_foreign_key 'template_combinations', :name => 'template_combinations_provisioning_template_id_fk'
    remove_foreign_key 'operatingsystems_provisioning_templates', :name => 'os_provisioning_template_id_fk'

    rename_column :template_combinations, :provisioning_template_id, :config_template_id
    rename_column :os_default_templates, :provisioning_template_id, :config_template_id

    rename_column :operatingsystems_provisioning_templates, :provisioning_template_id, :config_template_id
    rename_table :operatingsystems_provisioning_templates, :config_templates_operatingsystems

    add_foreign_key 'os_default_templates', 'config_templates', :name => 'os_default_templates_config_template_id_fk'
    add_foreign_key 'template_combinations', 'config_templates', :name => 'template_combinations_config_template_id_fk'
    add_foreign_key 'config_templates_operatingsystems', 'config_templates', :name => 'config_templates_operatingsystems_config_template_id_fk'
  end
end
