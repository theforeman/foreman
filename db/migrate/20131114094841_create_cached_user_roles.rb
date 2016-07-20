class CreateCachedUserRoles < ActiveRecord::Migration[4.2]
  def change
    create_table :cached_user_roles do |t|
      t.integer :user_id, :null => false
      t.integer :role_id, :null => false
      t.integer :user_role_id, :null => false

      t.timestamps null: true
    end

    add_index :cached_user_roles, :user_id
    add_index :cached_user_roles, :role_id
    add_index :cached_user_roles, :user_role_id
  end
end
