class RemoveUnusedPermissions < ActiveRecord::Migration
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
