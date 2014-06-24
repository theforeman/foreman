class FixPuppetclassCounters < ActiveRecord::Migration
  def up 
    # This is the counter for the total number of params for a given puppet class
    # across all environments.  It was poorly named.
    rename_column :puppetclasses, :lookup_keys_count, :global_class_params_count

    # Smart Variables Counts 
    add_column    :puppetclasses, :lookup_keys_count, :integer, :default => 0 
    LookupKey.where("puppetclass_id IS NOT NULL").each do |k|
      Puppetclass.reset_counters(k.puppetclass_id, :lookup_keys) 
    end
  end

  def down
    remove_column :puppetclasses, :lookup_keys_count 
    rename_column :puppetclasses, :global_class_params_count, :lookup_keys_count
  end
end
