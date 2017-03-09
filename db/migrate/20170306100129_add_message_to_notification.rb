class AddMessageToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :message, :string
    add_column :notifications, :actions, :text
  end
end
