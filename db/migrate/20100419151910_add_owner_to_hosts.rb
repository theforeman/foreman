class AddOwnerToHosts < ActiveRecord::Migration[4.2]
  def up
    add_column :hosts, :owner_id,   :integer
    add_column :hosts, :owner_type, :string, :limit => 255
  end

  def down
    remove_column :hosts, :owner_type
    remove_column :hosts, :owner_id
  end
end
