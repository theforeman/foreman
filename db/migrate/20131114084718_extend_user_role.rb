class ExtendUserRole < ActiveRecord::Migration[4.2]
  def up
    if foreign_key_exists?('user_roles', :name => 'user_roles_user_id_fk')
      remove_foreign_key 'user_roles', :name => 'user_roles_user_id_fk'
    end
    add_column :user_roles, :owner_type, :string, :default => 'User', :null => false, :limit => 255
    rename_column :user_roles, :user_id, :owner_id

    add_index :user_roles, :owner_type
    add_index :user_roles, :owner_id
    add_index :user_roles, [:owner_id, :owner_type]

    change_column :user_roles, :owner_id, :integer, :null => false
  end

  def down
    remove_index :user_roles, [:owner_id, :owner_type]
    remove_index :user_roles, :owner_id
    remove_index :user_roles, :owner_type

    rename_column :user_roles, :owner_id, :user_id
    remove_column :user_roles, :owner_type
    add_foreign_key 'user_roles', 'users', :name => 'user_roles_user_id_fk'
  end
end
