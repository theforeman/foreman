class FakeUser < ApplicationRecord
  self.table_name = 'users'
end

class ChangeNilAdminUsersToFalse < ActiveRecord::Migration[4.2]
  def up
    FakeUser.where(:admin => nil).update_all(:admin => false)
    change_column :users, :admin, :boolean, :null => false, :default => false
  end

  def down
    change_column :users, :admin, :boolean, :null => true, :default => nil
  end
end
