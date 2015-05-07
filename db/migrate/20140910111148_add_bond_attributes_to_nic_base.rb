require_dependency 'nic/base'

class AddBondAttributesToNicBase < ActiveRecord::Migration
  def up
    add_column :nics, :mode, :string, :null => false, :default => Nic::Bond::MODES.first
    add_column :nics, :attached_devices, :string, :default => '', :null => false
    add_column :nics, :bond_options, :string, :default => '', :null => false
    rename_column :nics, :physical_device, :attached_to
  end

  def down
    rename_column :nics, :attached_to, :physical_device
    remove_column :nics, :bond_options
    remove_column :nics, :attached_devices
    remove_column :nics, :mode
  end
end
