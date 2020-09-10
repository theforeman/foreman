class AddMessageToNotification < ActiveRecord::Migration[4.2]
  def change
    add_column :notifications, :message, :string
    add_column :notifications, :actions, :text
  end
end
