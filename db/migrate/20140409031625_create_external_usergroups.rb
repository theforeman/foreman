class CreateExternalUsergroups < ActiveRecord::Migration[4.2]
  def change
    create_table :external_usergroups do |t|
      t.string  :name,           :null => false, :limit => 255
      t.integer :auth_source_id, :null => false
      t.integer :usergroup_id,   :null => false
    end

    add_index :external_usergroups, :usergroup_id
    add_foreign_key "external_usergroups", "usergroups", :name => "external_usergroups_usergroup_id_fk"
    add_foreign_key "external_usergroups", "auth_sources", :name => "external_usergroups_auth_source_id_fk"
  end
end
