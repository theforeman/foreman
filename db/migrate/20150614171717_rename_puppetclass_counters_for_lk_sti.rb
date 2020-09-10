class RenamePuppetclassCountersForLkSti < ActiveRecord::Migration[4.2]
  def up
    # This is the counter for the total number of params for a given puppet class
    # across all environments.  It was poorly named.
    rename_column :puppetclasses, :lookup_keys_count, :variable_lookup_keys_count
  end

  def down
    rename_column :puppetclasses, :variable_lookup_keys_count, :lookup_keys_count
  end
end
