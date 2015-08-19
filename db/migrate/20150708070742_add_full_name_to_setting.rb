class AddFullNameToSetting < ActiveRecord::Migration
  def up
    add_column :settings, :full_name, :string
  end

  def down
    remove_column :settings, :full_name
  end
end
