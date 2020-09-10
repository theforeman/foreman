class RemoveHostCounterCache < ActiveRecord::Migration[4.2]
  def change
    remove_column :domains, :total_hosts, :integer, :default => 0
    remove_column :domains, :hostgroups_count, :integer, :default => 0
    remove_column :environments, :hosts_count, :integer, :default => 0
    remove_column :environments, :hostgroups_count, :integer, :default => 0
    remove_column :architectures, :hosts_count, :integer, :default => 0
    remove_column :architectures, :hostgroups_count, :integer, :default => 0
    remove_column :operatingsystems, :hosts_count, :integer, :default => 0
    remove_column :operatingsystems, :hostgroups_count, :integer, :default => 0
    remove_column :realms, :hosts_count, :integer, :default => 0
    remove_column :realms, :hostgroups_count, :integer, :default => 0
    remove_column :config_groups, :hosts_count, :integer, :default => 0
    remove_column :config_groups, :hostgroups_count, :integer, :default => 0
    remove_column :hostgroups, :hosts_count, :integer, :default => 0
    remove_column :models, :hosts_count, :integer, :default => 0
  end
end
