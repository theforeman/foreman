class AddVmDefaultsToHostgroup < ActiveRecord::Migration
  def up
    add_column :hostgroups, :vm_defaults, :text
  end

  def down
    remove_column :hostgroups, :vm_defaults
  end
end
