class UnifyPermissions < ActiveRecord::Migration[4.2]
  def up
    add_index :permissions, :name, :unique => true
  end

  def down
    remove_index :permissions, :name, :unique => true
  end
end
