class AddGatewayAndDnsToSubnets < ActiveRecord::Migration[4.2]
  def up
    add_column :subnets, :gateway, :string, :limit => 255
    add_column :subnets, :dns_primary, :string, :limit => 255
    add_column :subnets, :dns_secondary, :string, :limit => 255
  end

  def down
    remove_column :subnets, :gateway
    remove_column :subnets, :dns_primary
    remove_column :subnets, :dns_secondary
  end
end
