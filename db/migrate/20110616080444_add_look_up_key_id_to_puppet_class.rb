class AddLookUpKeyIdToPuppetClass < ActiveRecord::Migration[4.2]
  def up
    add_column :lookup_keys, :puppetclass_id, :integer
    add_index :lookup_keys, :puppetclass_id

    add_column :lookup_keys, :default_value, :string, :limit => 255
    add_column :lookup_keys, :path, :string, :limit => 255
    add_index :lookup_keys, :path

    add_column :lookup_keys, :description, :string, :limit => 255
    add_column :lookup_keys, :validator_type, :string, :limit => 255
    add_column :lookup_keys, :validator_rule, :string, :limit => 255
    rename_column :lookup_values, :priority, :match
  end

  def down
    remove_index :lookup_keys, :puppetclass_id
    remove_index :lookup_keys, :path
    remove_index :lookup_values, :match
    remove_column :lookup_keys, :puppetclass_id
    remove_column :lookup_keys, :path
    remove_column :lookup_keys, :description
    remove_column :lookup_keys, :validator_type
    remove_column :lookup_keys, :validator_rule
    rename_column :lookup_values, :match, :priority
  end
end
