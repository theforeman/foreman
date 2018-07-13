class AddIndexOnRoleNames < ActiveRecord::Migration[5.1]
  def change
    add_index :roles, :name, :unique => true
  end
end
