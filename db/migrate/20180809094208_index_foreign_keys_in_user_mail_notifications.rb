class IndexForeignKeysInUserMailNotifications < ActiveRecord::Migration[5.1]
  def change
    add_index :user_mail_notifications, :mail_notification_id
    add_index :user_mail_notifications, :user_id
  end
end
