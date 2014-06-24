class AddCountersToConfigGroups < ActiveRecord::Migration
  def change
    add_column :config_groups, :hosts_count, :integer
    add_column :config_groups, :hostgroups_count, :integer
    add_column :config_groups, :config_group_classes_count, :integer
  end
end
