class IndexForeignKeysInHosts < ActiveRecord::Migration[5.1]
  def change
    add_index :hosts, :compute_resource_id
    add_index :hosts, :discovery_rule_id
    add_index :hosts, :image_id
    add_index :hosts, :location_id
    add_index :hosts, :model_id
    add_index :hosts, :organization_id
    add_index :hosts, :owner_id
    add_index :hosts, :ptable_id
    add_index :hosts, :puppet_ca_proxy_id
    add_index :hosts, :puppet_proxy_id
    add_index :hosts, :realm_id
    add_index :hosts, :salt_environment_id
    add_index :hosts, :salt_proxy_id
  end
end
