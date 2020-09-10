class AddSubscribeToAllHostgroupsToUsers < ActiveRecord::Migration[4.2]
  def up
    add_column :users, :subscribe_to_all_hostgroups, :boolean unless column_exists? :users, :subscribe_to_all_hostgroups
  end

  def down
    remove_column :users, :subscribe_to_all_hostgroups if column_exists? :users, :subscribe_to_all_hostgroups
  end
end
