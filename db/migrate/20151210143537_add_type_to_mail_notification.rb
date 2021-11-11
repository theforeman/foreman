class AddTypeToMailNotification < ActiveRecord::Migration[4.2]
  def change
    add_column :mail_notifications, :type, :string, :limit => 255
  end
end
