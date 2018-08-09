class IndexForeignKeysInSubnetDomains < ActiveRecord::Migration[5.1]
  def change
    add_index :subnet_domains, :domain_id
  end
end
