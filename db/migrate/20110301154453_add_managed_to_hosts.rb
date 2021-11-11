class AddManagedToHosts < ActiveRecord::Migration[4.2]
  def up
    add_column :hosts, :managed, :boolean
  end

  def down
    remove_column :hosts, :managed
  end
end
