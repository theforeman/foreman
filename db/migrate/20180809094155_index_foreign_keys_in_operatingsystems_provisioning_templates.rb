class IndexForeignKeysInOperatingsystemsProvisioningTemplates < ActiveRecord::Migration[5.1]
  def change
    add_index :operatingsystems_provisioning_templates, :operatingsystem_id, name: 'index_os_ptemplate_on_operatingsystem_id'
    add_index :operatingsystems_provisioning_templates, :provisioning_template_id, name: 'index_os_ptemplate_on_provisioning_template_id'
  end
end
