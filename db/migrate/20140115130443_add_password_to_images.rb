class AddPasswordToImages < ActiveRecord::Migration
  def change
    add_column :images, :password, :string
  end
end
