class AddEncryptedToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :encrypted, :boolean, :null => false, :default => false
  end
end
