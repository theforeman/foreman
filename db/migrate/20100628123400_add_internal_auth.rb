require 'facter'
class AddInternalAuth < ActiveRecord::Migration
  def self.up
    add_column :users, :password_hash, :string, :limit => 128
    add_column :users, :password_salt, :string, :limit => 128
  end

  def self.down
    remove_column :users, :password_salt
    remove_column :users, :password_hash
  end
end
