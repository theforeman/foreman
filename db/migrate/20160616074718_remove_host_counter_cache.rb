class RemoveHostCounterCache < ActiveRecord::Migration
  def up
    remove_columns :domains, :total_hosts, :hostgroups_count
    remove_columns :environments, :hosts_count, :hostgroups_count
    remove_columns :architectures, :hosts_count, :hostgroups_count
    remove_columns :operatingsystems, :hosts_count, :hostgroups_count
    remove_columns :realms, :hosts_count, :hostgroups_count
    remove_columns :config_groups, :hosts_count, :hostgroups_count
    remove_column :hostgroups, :hosts_count
    remove_column :models, :hosts_count
  end
  def down
    add_column :domains, :total_hosts, :integer
    add_column :domains, :hostgroups_count, :integer
    add_column :environments, :hosts_count, :integer
    add_column :environments, :hostgroups_count, :integer
    add_column :architectures, :hosts_count, :integer
    add_column :architectures, :hostgroups_count, :integer
    add_column :operatingsystems, :hosts_count, :integer
    add_column :operatingsystems, :hostgroups_count, :integer
    add_column :realms, :hosts_count, :integer
    add_column :realms, :hostgroups_count, :integer
    add_column :config_groups, :hosts_count, :integer
    add_column :config_groups, :hostgroups_count, :integer
    add_column :hostgroups, :hosts_count, :integer
    add_column :models, :hosts_count, :integer
  end
end
