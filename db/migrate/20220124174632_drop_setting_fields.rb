class DropSettingFields < ActiveRecord::Migration[6.0]
  def up
    remove_column :settings, :description
    remove_column :settings, :settings_type
    remove_column :settings, :default
    remove_column :settings, :full_name
    remove_column :settings, :encrypted
    Setting.where(value: nil).delete_all
  end

  def down
    add_column :settings, :description, :text
    add_column :settings, :settings_type, :string, :limit => 255
    add_column :settings, :default, :text
    add_column :settings, :full_name, :string, :limit => 255
    add_column :settings, :encrypted, :boolean, :null => false, :default => false
  end
end
