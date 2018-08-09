class IndexForeignKeysInExternalUsergroups < ActiveRecord::Migration[5.1]
  def change
    add_index :external_usergroups, :auth_source_id
  end
end
