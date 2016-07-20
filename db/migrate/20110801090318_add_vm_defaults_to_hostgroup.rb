class AddVmDefaultsToHostgroup < ActiveRecord::Migration[4.2]
  def up
    add_column :hostgroups, :vm_defaults, :text
  end

  def down
    remove_column :hostgroups, :vm_defaults
  end
end
