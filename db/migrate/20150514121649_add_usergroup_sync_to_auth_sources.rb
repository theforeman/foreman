class AddUsergroupSyncToAuthSources < ActiveRecord::Migration
  def change
    add_column :auth_sources, :usergroup_sync, :boolean, :null => false, :default => true
  end
end
