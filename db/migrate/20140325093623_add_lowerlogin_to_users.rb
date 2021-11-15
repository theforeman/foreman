class AddLowerloginToUsers < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :lower_login, :string, :limit => 255
    add_index  :users, :lower_login, :unique => true

    # reset the column information in case any future migration relies on
    # User.find_by_lower_login method
    User.reset_column_information
  end

  def down
    remove_index  :users, :lower_login
    remove_column :users, :lower_login
  end
end
