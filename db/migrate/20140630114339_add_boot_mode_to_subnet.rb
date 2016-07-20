class AddBootModeToSubnet < ActiveRecord::Migration[4.2]
  class FakeSubnet < ApplicationRecord
    self.table_name = 'subnets'
  end

  def up
    add_column :subnets, :boot_mode, :string, :default => Subnet::BOOT_MODES[:static], :null => false, :limit => 255

    FakeSubnet.reset_column_information
    FakeSubnet.all.each do |subnet|
      real_subnet = Subnet.find(subnet.id)
      if real_subnet.dhcp?
        say "Subnet '#{subnet.name}' has dhcp proxy, setting boot mode to #{Subnet::BOOT_MODES[:dhcp]}"
        subnet.boot_mode = Subnet::BOOT_MODES[:dhcp]
        subnet.save!
      end
    end
  end

  def down
    remove_column :subnets, :boot_mode
  end
end
