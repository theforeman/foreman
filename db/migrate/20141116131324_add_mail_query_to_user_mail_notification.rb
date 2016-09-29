class AddMailQueryToUserMailNotification < ActiveRecord::Migration
  def change
    add_column :user_mail_notifications, :mail_query, :string, :limit => 255
  end
end
