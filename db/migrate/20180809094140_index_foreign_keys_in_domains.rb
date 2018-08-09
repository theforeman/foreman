class IndexForeignKeysInDomains < ActiveRecord::Migration[5.1]
  def change
    add_index :domains, :dns_id
  end
end
