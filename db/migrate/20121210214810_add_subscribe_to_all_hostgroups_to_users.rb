class AddSubscribeToAllHostgroupsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :subscribe_to_all_hostgroups, :boolean unless column_exists? :users, :subscribe_to_all_hostgroups
  end

  def self.down
    remove_column :users, :subscribe_to_all_hostgroups if column_exists? :users, :subscribe_to_all_hostgroups
  end
end
