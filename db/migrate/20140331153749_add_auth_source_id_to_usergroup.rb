class AddAuthSourceIdToUsergroup < ActiveRecord::Migration
  def change
    add_column :usergroups, :auth_source_id, :integer, :null => true
    add_foreign_key :usergroups, :auth_sources, :name => "usergroups_auth_source_id_fk"
    add_index :usergroups, [:name, :auth_source_id], :unique => true
  end

  def up
    if (internal = AuthSourceInternal.first).present?
      Usergroup.update_all(:auth_source_id => internal.id)
    end
    change_column :usergroups, :auth_source_id, :null => false
  end
end
