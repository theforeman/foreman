class AddSkipIfEmptyToUserMailNotifications < ActiveRecord::Migration[7.0]
  def change
    add_column :user_mail_notifications, :skip_if_empty, :boolean, default: false
  end
end
