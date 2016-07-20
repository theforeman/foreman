class AddEncryptedToSettings < ActiveRecord::Migration[4.2]
  def change
    add_column :settings, :encrypted, :boolean, :null => false, :default => false
  end
end
