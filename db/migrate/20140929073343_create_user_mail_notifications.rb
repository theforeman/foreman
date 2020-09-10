class CreateUserMailNotifications < ActiveRecord::Migration[4.2]
  def change
    create_table :user_mail_notifications do |t|
      t.integer :user_id
      t.integer :mail_notification_id
      t.datetime :last_sent
      t.string :interval, :limit => 255

      t.timestamps null: true
    end

    add_foreign_key :user_mail_notifications, :users, :name => "user_mail_notifications_user_id_fk"
    add_foreign_key :user_mail_notifications, :mail_notifications, :name => "user_mail_notifications_mail_notification_id_fk"
  end
end
