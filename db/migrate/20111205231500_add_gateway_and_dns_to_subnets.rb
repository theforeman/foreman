class AddGatewayAndDnsToSubnets < ActiveRecord::Migration
  def up
    add_column :subnets, :gateway, :string
    add_column :subnets, :dns_primary, :string
    add_column :subnets, :dns_secondary, :string
  end

  def down
    remove_column :subnets, :gateway
    remove_column :subnets, :dns_primary
    remove_column :subnets, :dns_secondary
  end
end
