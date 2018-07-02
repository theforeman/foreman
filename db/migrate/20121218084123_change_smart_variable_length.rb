class ChangeSmartVariableLength < ActiveRecord::Migration[4.2]
  def up
    change_column :lookup_keys, :default_value, :text
  end

  def down
    change_column :lookup_keys, :default_value, :string, :limit => 255
  end
end
