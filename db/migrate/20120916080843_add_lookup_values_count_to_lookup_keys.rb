class AddLookupValuesCountToLookupKeys < ActiveRecord::Migration
  def self.up
    add_column :lookup_keys, :lookup_values_count, :integer, :default => 0
  end

  def self.down
    remove_column :lookup_keys, :lookup_values_count
  end
end
