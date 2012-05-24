class AddDnsIdToSubnet < ActiveRecord::Migration
  def self.up
    add_column :subnets, :dns_id, :integer
  end

  def self.down
    remove_column :subnets, :dns_id
  end
end
