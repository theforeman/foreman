class AddHttpbootDoSubnet < ActiveRecord::Migration[5.1]
  def change
    add_column :subnets, :httpboot_id, :integer
    add_index :subnets, :httpboot_id
  end
end
