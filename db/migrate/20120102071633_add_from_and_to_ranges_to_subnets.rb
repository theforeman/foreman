class AddFromAndToRangesToSubnets < ActiveRecord::Migration[4.2]
  def up
    add_column :subnets, :from, :string, :limit => 255
    add_column :subnets, :to, :string, :limit => 255
    remove_column :subnets, :ranges
  end

  def down
    add_column :subnets, :ranges, :string, :limit => 255
    remove_column :subnets, :to
    remove_column :subnets, :from
  end
end
