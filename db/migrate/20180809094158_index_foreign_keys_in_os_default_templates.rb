class IndexForeignKeysInOsDefaultTemplates < ActiveRecord::Migration[5.1]
  def change
    add_index :os_default_templates, :operatingsystem_id
    add_index :os_default_templates, :provisioning_template_id
    add_index :os_default_templates, :template_kind_id
  end
end
