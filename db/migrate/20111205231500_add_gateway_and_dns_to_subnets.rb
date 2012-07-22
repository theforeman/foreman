class AddGatewayAndDnsToSubnets < ActiveRecord::Migration
  def self.up
    add_column :subnets, :gateway, :string
    add_column :subnets, :dns_primary, :string
    add_column :subnets, :dns_secondary, :string
  end

  def self.down
    remove_column :subnets, :gateway
    remove_column :subnets, :dns_primary
    remove_column :subnets, :dns_secondary
  end
end
