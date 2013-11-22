class CreateCachedUserRoles < ActiveRecord::Migration
  def change
    create_table :cached_user_roles do |t|
      t.integer :user_id, :null => false
      t.integer :role_id, :null => false
      t.integer :user_role_id, :null => false
      t.integer :user_membership_id

      t.timestamps
    end

    add_index :cached_user_roles, :user_id
    add_index :cached_user_roles, :role_id
    add_index :cached_user_roles, :user_role_id
    #add_index :cached_user_roles, :user_membership_id
  end
end
