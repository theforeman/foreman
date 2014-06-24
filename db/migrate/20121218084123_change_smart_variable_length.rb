class ChangeSmartVariableLength < ActiveRecord::Migration
  def self.up
    change_column :lookup_keys, :default_value, :text
  end

  def self.down
    change_column :lookup_keys, :default_value, :string
  end
end
