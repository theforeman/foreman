class AddSubscriptionTypeToMailNotifications < ActiveRecord::Migration
  def change
    add_column :mail_notifications, :subscription_type, :string, :limit => 255
  end
end
