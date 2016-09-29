class FakeUser < ActiveRecord::Base
  self.table_name = 'users'
end

class ChangeNilAdminUsersToFalse < ActiveRecord::Migration
  def up
    FakeUser.where(:admin => nil).update_all(:admin => false)
    change_column :users, :admin, :boolean, :null => false, :default => false
  end

  def down
    change_column :users, :admin, :boolean, :null => true, :default => nil
  end
end
