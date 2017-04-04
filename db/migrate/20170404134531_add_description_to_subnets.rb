class AddDescriptionToSubnets < ActiveRecord::Migration
  def change
    add_column :subnets, :description, :text
  end
end
