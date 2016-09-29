class AddMailEnabledToUser < ActiveRecord::Migration
  def change
    add_column :users, :mail_enabled, :boolean, :default => true
  end
end
