class RemovePuppetCounters < ActiveRecord::Migration[4.2]
  def change
    remove_column :puppetclasses, :total_hosts, :integer, :default => 0
    remove_column :puppetclasses, :global_class_params_count, :integer, :default => 0
    remove_column :puppetclasses, :variable_lookup_keys_count, :integer, :default => 0
    remove_column :lookup_keys, :lookup_values_count, :integer, :default => 0
  end
end
