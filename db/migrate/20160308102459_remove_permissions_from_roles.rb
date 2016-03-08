class RemovePermissionsFromRoles < ActiveRecord::Migration
  def up
    remove_column :roles, :permissions
  end

  def down
    add_column :roles, :permissions, :text
  end
end
