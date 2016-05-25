class AddCountersToConfigGroups < ActiveRecord::Migration
  def change
    add_column :config_groups, :hosts_count, :integer, :default => 0
    add_column :config_groups, :hostgroups_count, :integer, :default => 0
    add_column :config_groups, :config_group_classes_count, :integer, :default => 0
  end
end
