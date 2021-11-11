class AddBootModeToSubnet < ActiveRecord::Migration[4.2]
  def up
    add_column :subnets, :boot_mode, :string, :default => Subnet::BOOT_MODES[:static], :null => false, :limit => 255
  end

  def down
    remove_column :subnets, :boot_mode
  end
end
