class AddConfigGroupCounterDefaults < ActiveRecord::Migration[4.2]
  def up
    change_column :config_groups, :hosts_count, :integer, :default => 0
    change_column :config_groups, :hostgroups_count, :integer, :default => 0
    change_column :config_groups, :config_group_classes_count, :integer, :default => 0
  end

  def down
    change_column :config_groups, :hosts_count, :integer
    change_column :config_groups, :hostgroups_count, :integer
    change_column :config_groups, :config_group_classes_count, :integer
  end
end
