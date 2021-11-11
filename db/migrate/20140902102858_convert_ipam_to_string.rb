class ConvertIpamToString < ActiveRecord::Migration[4.2]
  def up
    add_column :subnets, :ipam_tmp, :string, :default => IPAM::MODES[:dhcp], :null => false, :limit => 255

    remove_column :subnets, :ipam
    rename_column :subnets, :ipam_tmp, :ipam
  end

  def down
    add_column :subnets, :ipam_tmp, :boolean, :default => true, :null => false

    remove_column :subnets, :ipam
    rename_column :subnets, :ipam_tmp, :ipam
  end
end
