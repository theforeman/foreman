class AddManagedToNics < ActiveRecord::Migration[4.2]
  def change
    add_column :nics, :managed, :boolean, :default => true
  end
end
