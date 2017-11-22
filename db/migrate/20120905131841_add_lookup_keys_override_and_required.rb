class AddLookupKeysOverrideAndRequired < ActiveRecord::Migration[4.2]
  def up
    add_column :lookup_keys, :is_param, :boolean, :default => false
    add_column :lookup_keys, :key_type, :string,  :default => nil, :limit => 255
    add_column :lookup_keys, :override, :boolean, :default => false
    add_column :lookup_keys, :required, :boolean, :default => false
  end

  def down
    remove_column :lookup_keys, :is_param
    remove_column :lookup_keys, :key_type
    remove_column :lookup_keys, :override
    remove_column :lookup_keys, :required
  end
end
