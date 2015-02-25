class ChangeDefaultSubnetBootMode < ActiveRecord::Migration
  def up
    change_column :subnets, :boot_mode, :string, :default => Subnet::BOOT_MODES[:dhcp]
  end

  def down
    change_column :subnets, :boot_mode, :string, :default => Subnet::BOOT_MODES[:static]
  end
end
