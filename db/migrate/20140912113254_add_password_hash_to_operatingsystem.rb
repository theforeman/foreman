class AddPasswordHashToOperatingsystem < ActiveRecord::Migration
  def change
    add_column :operatingsystems, :password_hash, :string, :default => 'MD5', :limit => 255
  end
end
