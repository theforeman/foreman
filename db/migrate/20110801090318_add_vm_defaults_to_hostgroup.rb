class AddVmDefaultsToHostgroup < ActiveRecord::Migration
  def self.up
    add_column :hostgroups, :vm_defaults, :text
  end

  def self.down
    remove_column :hostgroups, :vm_defaults
  end
end
