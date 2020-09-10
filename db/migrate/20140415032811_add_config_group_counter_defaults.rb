class AddConfigGroupCounterDefaults < ActiveRecord::Migration[4.2]
  def up
    change_column :config_groups, :hosts_count, :integer, :default => 0
    change_column :config_groups, :hostgroups_count, :integer, :default => 0
    change_column :config_groups, :config_group_classes_count, :integer, :default => 0
    ConfigGroup.unscoped.where(:hosts_count => nil).update_all(:hosts_count => 0)
    ConfigGroup.unscoped.where(:hostgroups_count => nil).update_all(:hostgroups_count => 0)
    ConfigGroup.unscoped.where(:config_group_classes_count => nil).update_all(:config_group_classes_count => 0)
  end

  def down
    change_column :config_groups, :hosts_count, :integer
    change_column :config_groups, :hostgroups_count, :integer
    change_column :config_groups, :config_group_classes_count, :integer
    ConfigGroup.unscoped.where(:hosts_count => 0).update_all(:hosts_count => nil)
    ConfigGroup.unscoped.where(:hostgroups_count => 0).update_all(:hostgroups_count => nil)
    ConfigGroup.unscoped.where(:config_group_classes_count => 0).update_all(:config_group_classes_count => nil)
  end
end
