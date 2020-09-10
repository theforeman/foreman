class AddNicDelayToSubnet < ActiveRecord::Migration[5.2]
  def change
    add_column :subnets, :nic_delay, :integer, :limit => 4
  end
end
