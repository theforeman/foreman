class AddUICompactModeToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :ui_compact_mode, :boolean, :default => false
  end
end
