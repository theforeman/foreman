class AddSkippableToMailNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :mail_notifications, :skippable, :boolean, default: false
  end
end
