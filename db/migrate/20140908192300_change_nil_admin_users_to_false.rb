class FakeUser < ActiveRecord::Base
  set_table_name 'users'
end

class ChangeNilAdminUsersToFalse < ActiveRecord::Migration
  def self.up
    FakeUser.where(:admin => nil).update_all(:admin => false)
    change_column :users, :admin, :boolean, :null => false, :default => false
  end

  def self.down
    change_column :users, :admin, :boolean, :null => true, :default => nil
  end
end
