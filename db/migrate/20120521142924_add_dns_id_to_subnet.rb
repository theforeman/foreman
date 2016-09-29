class AddDnsIdToSubnet < ActiveRecord::Migration
  def up
    add_column :subnets, :dns_id, :integer
  end

  def down
    remove_column :subnets, :dns_id
  end
end
