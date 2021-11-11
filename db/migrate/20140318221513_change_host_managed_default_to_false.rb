class ChangeHostManagedDefaultToFalse < ActiveRecord::Migration[4.2]
  def up
    change_column :hosts, :managed, :boolean, :null => false, :default => false
  end

  def down
    change_column :hosts, :managed, :boolean, :null => true
  end
end
