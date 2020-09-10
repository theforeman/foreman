class AddMailQueryToUserMailNotification < ActiveRecord::Migration[4.2]
  def change
    add_column :user_mail_notifications, :mail_query, :string, :limit => 255
  end
end
