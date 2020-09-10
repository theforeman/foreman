class AddMissingIndexesToNotification < ActiveRecord::Migration[4.2]
  def change
    add_index :notifications, :expired_at
    add_index :notification_recipients, [:user_id, :notification_id]
  end
end
