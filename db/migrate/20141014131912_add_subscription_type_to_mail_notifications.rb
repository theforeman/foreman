class AddSubscriptionTypeToMailNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column :mail_notifications, :subscription_type, :string, :limit => 255
  end
end
