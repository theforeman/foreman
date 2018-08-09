class IndexForeignKeysInUsers < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :auth_source_id
    add_index :users, :default_location_id
    add_index :users, :default_organization_id
  end
end
