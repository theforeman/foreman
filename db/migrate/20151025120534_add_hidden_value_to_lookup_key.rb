class AddHiddenValueToLookupKey < ActiveRecord::Migration
  def change
    add_column :lookup_keys, :hidden_value, :boolean, :default => false
  end
end
