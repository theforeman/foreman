class AddFullNameToSetting < ActiveRecord::Migration[4.2]
  def up
    add_column :settings, :full_name, :string, :limit => 255
  end

  def down
    remove_column :settings, :full_name
  end
end
