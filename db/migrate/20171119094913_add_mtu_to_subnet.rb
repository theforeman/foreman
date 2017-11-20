class AddMtuToSubnet < ActiveRecord::Migration[4.2]
  def change
    add_column :subnets, :mtu, :integer, :default => 1500, :null => false, :limit => 8
  end
end
