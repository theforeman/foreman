class AddLookupKeysOverrideAndRequired < ActiveRecord::Migration
  def self.up
    add_column :lookup_keys, :is_param, :boolean, :default => false
    add_column :lookup_keys, :key_type, :string , :default => nil
    add_column :lookup_keys, :override, :boolean, :default => false
    add_column :lookup_keys, :required, :boolean, :default => false
  end

  def self.down
    remove_column :lookup_keys, :is_param
    remove_column :lookup_keys, :key_type
    remove_column :lookup_keys, :override
    remove_column :lookup_keys, :required
  end
end
