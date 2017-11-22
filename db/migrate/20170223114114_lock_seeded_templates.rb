require Rails.root + 'db/seeds.d/020-provisioning_templates_list.rb'
require Rails.root + 'db/seeds.d/020-partition_tables_list.rb'

class LockSeededTemplates < ActiveRecord::Migration[4.2]
  def up
    names = (ProvisioningTemplatesList.seeded_templates + PartitionTablesList.seeded_templates).map { |attrs| attrs[:name] }
    Template.where(:name => names).update_all(:locked => true)
  end

  def down
    names = (ProvisioningTemplatesList.seeded_templates + PartitionTablesList.seeded_templates).map { |attrs| attrs[:name] }
    Template.where(:name => names).update_all(:locked => false)
  end
end
