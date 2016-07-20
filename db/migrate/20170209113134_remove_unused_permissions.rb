class RemoveUnusedPermissions < ActiveRecord::Migration[4.2]
  def up
    permission = Permission.where(:name => 'access_settings').first
    if permission.present?
      permission.filterings.delete_all
      permission.destroy
    end
  end

  def down
    # ignoring
  end
end
