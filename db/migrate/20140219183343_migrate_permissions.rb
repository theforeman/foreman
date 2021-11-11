class MigratePermissions < ActiveRecord::Migration[4.2]
  def up
    # This migration was used to migrate from role-based permissions to the current
    # permissions model in 1.7. It is no longer needed and was cleaned up.
  end

  def down
  end
end
