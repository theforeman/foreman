class AddIpv6Subnet < ActiveRecord::Migration[4.2]
  def self.up
    change_column :subnets, :network, :string, :limit => 45
    change_column :subnets, :mask, :string, :limit => 45
    change_column :subnets, :gateway, :string, :limit => 45
    change_column :subnets, :dns_primary, :string, :limit => 45
    change_column :subnets, :dns_secondary, :string, :limit => 45
    change_column :subnets, :from, :string, :limit => 45
    change_column :subnets, :to, :string, :limit => 45

    change_column_default :subnets, :ipam, 'None'
  end

  def self.down
    change_column :subnets, :network, :string, :limit => 15
    change_column :subnets, :mask, :string, :limit => 15
    change_column :subnets, :gateway, :string
    change_column :subnets, :dns_primary, :string
    change_column :subnets, :dns_secondary, :string
    change_column :subnets, :from, :string
    change_column :subnets, :to, :string

    change_column_default :subnets, :ipam, 'DHCP'
  end
end
