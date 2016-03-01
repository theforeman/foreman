class AddPasswordToImages < ActiveRecord::Migration
  def change
    add_column :images, :password, :string, :limit => 255
  end
end
