class IndexForeignKeysInRealms < ActiveRecord::Migration[5.1]
  def change
    add_index :realms, :realm_proxy_id
  end
end
