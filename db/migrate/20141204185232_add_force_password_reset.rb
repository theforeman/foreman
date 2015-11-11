class AddForcePasswordReset < ActiveRecord::Migration
  def up
    add_column :users, :force_password_reset, :boolean, :default => true
  end

  def down
    remove_column :users, :force_password_reset
  end
end
