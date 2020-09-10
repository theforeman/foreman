class AddUsergroupSyncToAuthSources < ActiveRecord::Migration[4.2]
  def change
    add_column :auth_sources, :usergroup_sync, :boolean, :null => false, :default => true
  end
end
