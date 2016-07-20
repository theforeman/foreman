class AddMailEnabledToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :mail_enabled, :boolean, :default => true
  end
end
