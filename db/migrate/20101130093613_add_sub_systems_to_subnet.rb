class AddSubSystemsToSubnet < ActiveRecord::Migration[4.2]
  def up
    add_column :subnets, :dhcp_id, :integer
    add_column :subnets, :tftp_id, :integer
    rename_column :subnets, :number, :network
  end

  def down
    remove_column :subnets, :dhcp_id
    remove_column :subnets, :tftp_id
    rename_column :subnets, :network, :number
  end
end
