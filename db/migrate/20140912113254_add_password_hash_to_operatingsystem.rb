class AddPasswordHashToOperatingsystem < ActiveRecord::Migration[4.2]
  def change
    add_column :operatingsystems, :password_hash, :string, :default => 'MD5', :limit => 255
  end
end
