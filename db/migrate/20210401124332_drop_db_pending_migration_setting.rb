class DropDbPendingMigrationSetting < ActiveRecord::Migration[6.0]
  def up
    Setting.where(name: 'db_pending_migration').delete_all
  end
end
