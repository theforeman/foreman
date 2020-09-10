class AddStiToLookupKeys < ActiveRecord::Migration[4.2]
  def up
    add_column :lookup_keys, :type, :string, :limit => 255
    LookupKey.where(:is_param => true).update_all(:type => 'PuppetclassLookupKey')
    LookupKey.where(:is_param => false).update_all(:type => 'VariableLookupKey')
    add_index :lookup_keys, :type

    remove_foreign_key :environment_classes, :lookup_keys if foreign_key_exists?(:environment_classes, :lookup_keys)
    rename_column :environment_classes, :lookup_key_id, :puppetclass_lookup_key_id
    add_foreign_key :environment_classes, :lookup_keys, :column => :puppetclass_lookup_key_id, :name => "environment_classes_lookup_key_id_fk"
  end

  def down
    LookupKey.where(:type => "PuppetclassLookupKey").update_all(:is_param => true)
    remove_column :lookup_keys, :type

    remove_foreign_key :environment_classes, :lookup_keys if foreign_key_exists?(:environment_classes, :lookup_keys)
    rename_column :environment_classes, :puppetclass_lookup_key_id, :lookup_key_id
    add_foreign_key :environment_classes, :lookup_keys
  end
end
