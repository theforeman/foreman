class ChangeSmartVariableLength < ActiveRecord::Migration
  def up
    change_column :lookup_keys, :default_value, :text
  end

  def down
    change_column :lookup_keys, :default_value, :string
  end
end
