class ConvertIpamToString < ActiveRecord::Migration[4.2]
  def up
    change_column :subnets, :ipam, :string, :default => IPAM::MODES[:dhcp], :null => false, :limit => 255
  end

  def down
    change_column :subnets, :ipam, :boolean, :default => true, :null => false
  end
end
