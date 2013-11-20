class RenameHost < ActiveRecord::Migration
  def up
    rename_column :auth_sources,          :host, :system
    rename_column :fact_values,           :host_id, :system_id
    rename_column :host_classes,          :host_id, :system_id
    rename_column :hostgroup_classes,     :hostgroup_id, :system_group_id
    rename_column :hosts,                 :hostgroup_id, :system_group_id
    rename_column :nics,                  :host_id, :system_id
    rename_column :reports,               :host_id, :system_id
    rename_column :resources,             :host_id, :system_id
    rename_column :template_combinations, :hostgroup_id, :system_group_id
    rename_column :user_hostgroups,       :hostgroup_id, :system_group_id
    rename_column :users,                 :hostgroups_andor, :system_groups_andor
    rename_column :users,                 :subscribe_to_all_hostgroups, :subscribe_to_all_system_groups
    rename_column :tokens,                :host_id, :system_id

    rename_table :hosts,                  :systems
    rename_table :hostgroups,             :system_groups
    rename_table :host_classes,           :system_classes
    rename_table :hostgroup_classes,      :system_group_classes
    rename_table :user_hostgroups,        :user_system_groups
  end

  def down
    rename_table :systems,                :hosts
    rename_table :system_groups,          :hostgroups
    rename_table :system_classes,         :host_classes
    rename_table :system_group_classes,   :hostgroup_classes
    rename_table :user_system_groups,     :user_hostgroups

    rename_column :auth_sources,          :system, :host
    rename_column :fact_values,           :system_id, :host_id
    rename_column :host_classes,          :system_id, :host_id
    rename_column :hostgroup_classes,     :system_group_id, :hostgroup_id
    rename_column :hosts,                 :system_group_id, :hostgroup_id
    rename_column :nics,                  :system_id, :host_id
    rename_column :reports,               :system_id, :host_id
    rename_column :resources,             :system_id, :host_id
    rename_column :template_combinations, :system_group_id, :hostgroup_id
    rename_column :user_hostgroups,       :system_group_id, :hostgroup_id
    rename_column :users,                 :system_groups_andor, :hostgroups_andor
    rename_column :users,                 :subscribe_to_all_system_groups, :subscribe_to_all_hostgroups
    rename_column :tokens,             :system_id, :host_id
  end
end
