class AddStiToSubnet < ActiveRecord::Migration
  def self.up
    add_column :subnets, :type, :string, :default => 'Subnet::Ipv4'
    execute "UPDATE subnets set type='Subnet::Ipv4'"
    add_index :subnets, :type

    change_column :subnets, :network, :string, :limit => 45
    change_column :subnets, :mask, :string, :limit => 45
    change_column :subnets, :gateway, :string, :limit => 45
    change_column :subnets, :dns_primary, :string, :limit => 45
    change_column :subnets, :dns_secondary, :string, :limit => 45
    change_column :subnets, :from, :string, :limit => 45
    change_column :subnets, :to, :string, :limit => 45

    change_column_default :subnets, :ipam, 'None'

    change_column :nics, :ip, :string, :limit => 15
    add_column :nics, :ip6, :string, :limit => 45
    add_column :hostgroups, :subnet6_id, :integer
    add_column :nics, :subnet6_id, :integer
  end

  def self.down
    Subnet::Ipv6.destroy_all
    remove_column :subnets, :type

    change_column :subnets, :network, :string, :limit => 15
    change_column :subnets, :mask, :string, :limit => 15
    change_column :subnets, :gateway, :string
    change_column :subnets, :dns_primary, :string
    change_column :subnets, :dns_secondary, :string
    change_column :subnets, :from, :string
    change_column :subnets, :to, :string

    change_column_default :subnets, :ipam, 'DHCP'

    change_column :nics, :ip, :string
    remove_column :nics, :ip6
    remove_column :hostgroups, :subnet6_id
    remove_column :nics, :subnet6_id
  end
end
