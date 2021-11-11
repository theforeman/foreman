class AddLowerloginToUsers < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :lower_login, :string, :limit => 255
    add_index  :users, :lower_login, :unique => true
  end

  def down
    remove_index  :users, :lower_login
    remove_column :users, :lower_login
  end
end
