class RemovePermissionsFromRoles < ActiveRecord::Migration[4.2]
  def up
    remove_column :roles, :permissions
  end

  def down
    add_column :roles, :permissions, :text
  end
end
