class AddHiddenValueToLookupKey < ActiveRecord::Migration[4.2]
  def change
    add_column :lookup_keys, :hidden_value, :boolean, :default => false
  end
end
