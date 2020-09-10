class AddCounterCaches < ActiveRecord::Migration[4.2]
  def up
    # Architectures
    add_column :architectures, :hosts_count, :integer, :default => 0
    add_column :architectures, :hostgroups_count, :integer, :default => 0

    # Domains
    add_column :domains, :hosts_count, :integer, :default => 0
    add_column :domains, :hostgroups_count, :integer, :default => 0

    # Environments
    add_column :environments, :hosts_count, :integer, :default => 0
    add_column :environments, :hostgroups_count, :integer, :default => 0

    # Hardware Models
    add_column :models, :hosts_count, :integer, :default => 0

    # Operating Systems
    add_column :operatingsystems, :hosts_count, :integer, :default => 0
    add_column :operatingsystems, :hostgroups_count, :integer, :default => 0

    # Puppetclasses
    add_column :puppetclasses, :hosts_count, :integer, :default => 0
    add_column :puppetclasses, :hostgroups_count, :integer, :default => 0

    add_column :puppetclasses, :lookup_keys_count, :integer, :default => 0
  end

  def down
    remove_column :architectures,    :hosts_count
    remove_column :architectures,    :hostgroups_count

    remove_column :domains,          :hosts_count
    remove_column :domains,          :hostgroups_count

    remove_column :environments,     :hosts_count
    remove_column :environments,     :hostgroups_count

    remove_column :models,           :hosts_count

    remove_column :operatingsystems, :hosts_count
    remove_column :operatingsystems, :hostgroups_count

    remove_column :puppetclasses,    :hosts_count
    remove_column :puppetclasses,    :hostgroups_count
    remove_column :puppetclasses,    :lookup_keys_count
  end
end
