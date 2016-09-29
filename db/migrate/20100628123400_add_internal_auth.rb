require 'facter'
class AddInternalAuth < ActiveRecord::Migration
  def up
    add_column :users, :password_hash, :string, :limit => 128
    add_column :users, :password_salt, :string, :limit => 128
  end

  def down
    remove_column :users, :password_salt
    remove_column :users, :password_hash
  end
end
