class AddIdToJoinTablesHostgroupsAndOperatingSystems < ActiveRecord::Migration
  def self.up
    add_column :hostgroups_puppetclasses, :id, :primary_key
    add_column :operatingsystems_puppetclasses, :id, :primary_key
  end

  def self.down
    remove_column :hostgroups_puppetclasses, :id
    remove_column :operatingsystems_puppetclasses, :id
  end
end
