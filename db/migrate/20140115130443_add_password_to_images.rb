class AddPasswordToImages < ActiveRecord::Migration[4.2]
  def change
    add_column :images, :password, :string, :limit => 255
  end
end
