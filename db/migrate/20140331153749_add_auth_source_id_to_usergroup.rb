class AddAuthSourceIdToUsergroup < ActiveRecord::Migration
  def change
    add_column :usergroups, :auth_source_id, :integer, :default => AuthSourceInternal.first.id, :null => false;
  end
end
