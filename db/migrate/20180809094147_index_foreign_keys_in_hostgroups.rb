class IndexForeignKeysInHostgroups < ActiveRecord::Migration[5.1]
  def change
    add_index :hostgroups, :architecture_id
    add_index :hostgroups, :compute_resource_id
    add_index :hostgroups, :domain_id
    add_index :hostgroups, :environment_id
    add_index :hostgroups, :medium_id
    add_index :hostgroups, :operatingsystem_id
    add_index :hostgroups, :ptable_id
    add_index :hostgroups, :puppet_ca_proxy_id
    add_index :hostgroups, :puppet_proxy_id
    add_index :hostgroups, :realm_id
    add_index :hostgroups, :salt_environment_id
    add_index :hostgroups, :salt_proxy_id
    add_index :hostgroups, :subnet6_id
    add_index :hostgroups, :subnet_id
  end
end
