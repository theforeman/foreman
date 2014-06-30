class AddManagedToNics < ActiveRecord::Migration
  def change
    add_column :nics, :managed, :boolean, :default => true
  end
end
