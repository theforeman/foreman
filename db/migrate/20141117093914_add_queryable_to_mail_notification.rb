class AddQueryableToMailNotification < ActiveRecord::Migration
  def change
    add_column :mail_notifications, :queryable, :boolean, :default => false
  end
end
