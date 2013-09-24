class RemoveUnusedRoleFields < ActiveRecord::Migration
  def up
    remove_column :users, :role_id
    remove_column :user_roles, :inherited_from
  end

  def down
    add_column :users, :role_id, :integer
    add_column :user_roles, :inherited_from, :integer
  end
end
