class CreateHostgroupClasses < ActiveRecord::Migration
  def self.up
    rename_table :hostgroups_puppetclasses, :hostgroup_classes
    add_column :hostgroup_classes, :id, :primary_key
  end

  def self.down
    remove_column :hostgroup_classes, :id
    rename_table :hostgroup_classes, :hostgroups_puppetclasses
  end
end
