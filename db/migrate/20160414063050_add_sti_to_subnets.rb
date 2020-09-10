class AddStiToSubnets < ActiveRecord::Migration[4.2]
  def self.up
    add_column :subnets, :type, :string, :default => 'Subnet::Ipv4', :null => false
    add_index :subnets, :type
  end

  def self.down
    remove_column :subnets, :type
  end
end
