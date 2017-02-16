class ProxiesHavePools < ActiveRecord::Migration[5.1]
  def up
    create_table :smart_proxy_pools do |t|
      t.text :name
      t.string :hostname, :limit => 255
      t.timestamps :null => true
    end

    create_table :pools_smart_proxies do |t|
      t.belongs_to :smart_proxy, index: true
      t.belongs_to :smart_proxy_pool, index: true
    end

    User.without_auditing do
      SmartProxy.unscoped.each do |proxy|
        SmartProxyPool.new(:name => proxy.name, :hostname => proxy.hostname, :smart_proxies => [proxy]).save!
      end
    end

    add_column :hosts, :puppet_ca_proxy_pool_id, :bigint
    add_column :hosts, :puppet_proxy_pool_id, :bigint
    Host.unscoped.each do |host|
      if host.read_attribute(:puppet_ca_proxy_id)
        host.puppet_ca_proxy_pool_id = SmartProxy.unscoped.find(host.read_attribute(:puppet_ca_proxy_id)).pools.first.id
      end
      if host.read_attribute(:puppet_proxy_id)
        host.puppet_proxy_pool_id = SmartProxy.unscoped.find(host.read_attribute(:puppet_proxy_id)).pools.first.id
      end
      host.save(:validate => false)
    end
    remove_foreign_key :hosts, :name => "hosts_puppet_ca_proxy_id_fk"
    remove_column :hosts, :puppet_ca_proxy_id, :integer

    remove_foreign_key :hosts, :name => "hosts_puppet_proxy_id_fk"
    remove_column :hosts, :puppet_proxy_id, :integer

    add_column :hostgroups, :puppet_ca_proxy_pool_id, :bigint
    add_column :hostgroups, :puppet_proxy_pool_id, :bigint
    Hostgroup.unscoped.each do |group|
      if group.read_attribute(:puppet_ca_proxy_id)
        group.puppet_ca_proxy_pool_id = SmartProxy.unscoped.find(group.read_attribute(:puppet_ca_proxy_id)).pools.first.id
      end
      if group.read_attribute(:puppet_proxy_id)
        group.puppet_proxy_pool_id = SmartProxy.unscoped.find(group.read_attribute(:puppet_proxy_id)).pools.first.id
      end
      group.save(:validate => false)
    end
    remove_foreign_key :hostgroups, :name => "hostgroups_puppet_ca_proxy_id_fk"
    remove_column :hostgroups, :puppet_ca_proxy_id, :integer

    remove_foreign_key :hostgroups, :name => "hostgroups_puppet_proxy_id_fk"
    remove_column :hostgroups, :puppet_proxy_id, :integer

    add_foreign_key "hostgroups", "smart_proxy_pools", :name => "hostgroups_puppet_ca_proxy_pools_id_fk", :column => "puppet_ca_proxy_pool_id"
    add_foreign_key "hostgroups", "smart_proxy_pools", :name => "hostgroups_puppet_proxy_pools_id_fk", :column => "puppet_proxy_pool_id"
    add_foreign_key "hosts", "smart_proxy_pools", :name => "hosts_puppet_ca_proxy_pools_id_fk", :column => "puppet_ca_proxy_pool_id"
    add_foreign_key "hosts", "smart_proxy_pools", :name => "hosts_puppet_proxy_pools_id_fk", :column => "puppet_proxy_pool_id"
  end

  def down
    add_column :hosts, :puppet_ca_proxy_id, :integer
    add_column :hosts, :puppet_proxy_id, :integer
    Host.unscoped.each do |host|
      if host.puppet_ca_proxy_pool_id
        host.puppet_ca_proxy_id = SmartProxy.unscoped.joins(:pools).where(smart_proxy_pools: { id: host.puppet_ca_proxy_pool_id }).try(:first).try(:id)
      end
      if host.puppet_proxy_pool_id
        host.puppet_proxy_id = SmartProxy.unscoped.joins(:pools).where(smart_proxy_pools: { id: host.puppet_proxy_pool_id }).try(:first).try(:id)
      end
      host.save(:validate => false)
    end
    remove_column :hosts, :puppet_ca_proxy_pool_id, :bigint
    remove_column :hosts, :puppet_proxy_pool_id, :bigint

    add_column :hostgroups, :puppet_ca_proxy_id, :integer
    add_column :hostgroups, :puppet_proxy_id, :integer
    Hostgroup.unscoped.each do |group|
      if group.puppet_ca_proxy_pool_id
        group.puppet_ca_proxy_id = SmartProxy.unscoped.joins(:pools).where(smart_proxy_pools: { id: group.puppet_ca_proxy_pool_id }).try(:first).try(:id)
      end
      if group.puppet_proxy_pool_id
        group.puppet_proxy_id = SmartProxy.unscoped.joins(:pools).where(smart_proxy_pools: { id: group.puppet_proxy_pool_id }).try(:first).try(:id)
      end
      group.save!(:validate => false)
    end
    remove_column :hostgroups, :puppet_ca_proxy_pool_id, :bigint
    remove_column :hostgroups, :puppet_proxy_pool_id, :bigint

    drop_table :pools_smart_proxies
    drop_table :smart_proxy_pools

    add_foreign_key "hostgroups", "smart_proxies", :name => "hostgroups_puppet_ca_proxy_id_fk", :column => "puppet_ca_proxy_id"
    add_foreign_key "hostgroups", "smart_proxies", :name => "hostgroups_puppet_proxy_id_fk", :column => "puppet_proxy_id"
    add_foreign_key "hosts", "smart_proxies", :name => "hosts_puppet_ca_proxy_id_fk", :column => "puppet_ca_proxy_id"
    add_foreign_key "hosts", "smart_proxies", :name => "hosts_puppet_proxy_id_fk", :column => "puppet_proxy_id"
  end
end
