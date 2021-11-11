class AddSubnetNameUniqueConstraint < ActiveRecord::Migration[5.1]
  def up
    add_index :subnets, :name, :unique => true
  end

  def down
    remove_index :subnets, :name
  end
end
