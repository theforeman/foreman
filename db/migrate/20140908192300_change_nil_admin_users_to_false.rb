class ChangeNilAdminUsersToFalse < ActiveRecord::Migration[4.2]
  def up
    change_column :users, :admin, :boolean, :null => false, :default => false
  end

  def down
    change_column :users, :admin, :boolean, :null => true, :default => nil
  end
end
