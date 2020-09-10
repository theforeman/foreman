class AddQueryableToMailNotification < ActiveRecord::Migration[4.2]
  def change
    add_column :mail_notifications, :queryable, :boolean, :default => false
  end
end
