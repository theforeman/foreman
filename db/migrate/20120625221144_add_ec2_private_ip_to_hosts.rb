class AddEc2PrivateIpToHosts < ActiveRecord::Migration
  def self.up
    add_column :hosts, :ec2_private_ip, :string
  end

  def self.down
    remove_column :hosts, :ec2_private_ip  end
end
