class AddSubSystemsToSubnet < ActiveRecord::Migration
  def self.up
    add_column :subnets, :dhcp_id, :integer
    add_column :subnets, :tftp_id, :integer
    rename_column :subnets, :number, :network
  end

  def self.down
    remove_column :subnets, :dhcp_id
    remove_column :subnets, :tftp_id
    rename_column :subnets, :network, :number
  end
end
