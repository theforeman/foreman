class ExtractNicAttributes < ActiveRecord::Migration[4.2]
  def up
    add_column :nics, :provider, :string, :limit => 255
    add_column :nics, :username, :string, :limit => 255
    add_column :nics, :password, :string, :limit => 255
  end

  def down
    remove_column :nics, :password
    remove_column :nics, :username
    remove_column :nics, :provider
  end
end
