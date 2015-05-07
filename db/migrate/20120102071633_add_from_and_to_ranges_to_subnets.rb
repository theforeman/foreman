class AddFromAndToRangesToSubnets < ActiveRecord::Migration
  def up
    add_column :subnets, :from, :string
    add_column :subnets, :to, :string
    remove_column :subnets, :ranges
  end

  def down
    add_column :subnets, :ranges, :string
    remove_column :subnets, :to
    remove_column :subnets, :from
  end
end
