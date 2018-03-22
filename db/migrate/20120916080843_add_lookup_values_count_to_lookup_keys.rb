class AddLookupValuesCountToLookupKeys < ActiveRecord::Migration[4.2]
  def up
    add_column :lookup_keys, :lookup_values_count, :integer, :default => 0
  end

  def down
    remove_column :lookup_keys, :lookup_values_count
  end
end
