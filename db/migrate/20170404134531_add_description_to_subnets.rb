class AddDescriptionToSubnets < ActiveRecord::Migration[4.2]
  def change
    add_column :subnets, :description, :text
  end
end
