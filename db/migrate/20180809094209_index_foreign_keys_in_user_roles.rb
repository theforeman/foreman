class IndexForeignKeysInUserRoles < ActiveRecord::Migration[5.1]
  def change
    add_index :user_roles, :role_id
  end
end
