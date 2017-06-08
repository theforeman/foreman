class ProxiesHaveMultipleHostnames < ActiveRecord::Migration
  def up
    create_table :hostnames do |t|
      t.text :name
      t.string :hostname, :limit => 255
      t.timestamps :null => true
    end

    create_table :hostnames_smart_proxies do |t|
      t.belongs_to :smart_proxy, index: true
      t.belongs_to :hostname, index: true
    end

    SmartProxy.unscoped.each do |proxy|
      proxy.hostnames << Hostname.new(:name => proxy.name, :hostname => proxy.hostname)
    end

    add_column :hosts, :puppet_ca_proxy_hostname_id, :integer
    add_column :hosts, :puppet_proxy_hostname_id, :integer
    Host.unscoped.each do |host|
      if host.read_attribute(:puppet_ca_proxy_id)
        host.puppet_ca_proxy_hostname_id = SmartProxy.unscoped.find(host.read_attribute(:puppet_ca_proxy_id)).hostnames.first.id
      end
      if host.read_attribute(:puppet_proxy_id)
        host.puppet_proxy_hostname_id = SmartProxy.unscoped.find(host.read_attribute(:puppet_proxy_id)).hostnames.first.id
      end
      host.save(:validate => false)
    end
    remove_foreign_key :hosts, :name => "hosts_puppet_ca_proxy_id_fk"
    remove_column :hosts, :puppet_ca_proxy_id, :integer

    remove_foreign_key :hosts, :name => "hosts_puppet_proxy_id_fk"
    remove_column :hosts, :puppet_proxy_id, :integer

    add_column :hostgroups, :puppet_ca_proxy_hostname_id, :integer
    add_column :hostgroups, :puppet_proxy_hostname_id, :integer
    Hostgroup.unscoped.each do |group|
      if group.read_attribute(:puppet_ca_proxy_id)
        group.puppet_ca_proxy_hostname_id = SmartProxy.unscoped.find(group.read_attribute(:puppet_ca_proxy_id)).hostnames.first.id
      end
      if group.read_attribute(:puppet_proxy_id)
        group.puppet_proxy_hostname_id = SmartProxy.unscoped.find(group.read_attribute(:puppet_proxy_id)).hostnames.first.id
      end
      group.save(:validate => false)
    end
    remove_foreign_key :hostgroups, :name => "hostgroups_puppet_ca_proxy_id_fk"
    remove_column :hostgroups, :puppet_ca_proxy_id, :integer

    remove_foreign_key :hostgroups, :name => "hostgroups_puppet_proxy_id_fk"
    remove_column :hostgroups, :puppet_proxy_id, :integer

    add_foreign_key "hostgroups", "hostnames", :name => "hostgroups_puppet_ca_proxy_hostnames_id_fk", :column => "puppet_ca_proxy_hostname_id"
    add_foreign_key "hostgroups", "hostnames", :name => "hostgroups_puppet_proxy_hostnames_id_fk", :column => "puppet_proxy_hostname_id"
    add_foreign_key "hosts", "hostnames", :name => "hosts_puppet_ca_proxy_hostnames_id_fk", :column => "puppet_ca_proxy_hostname_id"
    add_foreign_key "hosts", "hostnames", :name => "hosts_puppet_proxy_hostnames_id_fk", :column => "puppet_proxy_hostname_id"
  end

  def down
    add_column :hosts, :puppet_ca_proxy_id, :integer
    add_column :hosts, :puppet_proxy_id, :integer
    Host.unscoped.each do |host|
      if host.puppet_ca_proxy_hostname_id
        host.puppet_ca_proxy_id = SmartProxy.unscoped.joins(:hostnames).where(hostnames: { id: host.puppet_ca_proxy_hostname_id }).try(:first).try(:id)
      end
      if host.puppet_proxy_hostname_id
        host.puppet_proxy_id = SmartProxy.unscoped.joins(:hostnames).where(hostnames: { id: host.puppet_proxy_hostname_id }).try(:first).try(:id)
      end
      host.save(:validate => false)
    end
    remove_column :hosts, :puppet_ca_proxy_hostname_id, :integer
    remove_column :hosts, :puppet_proxy_hostname_id, :integer

    add_column :hostgroups, :puppet_ca_proxy_id, :integer
    add_column :hostgroups, :puppet_proxy_id, :integer
    Hostgroup.unscoped.each do |group|
      if group.puppet_ca_proxy_hostname_id
        group.puppet_ca_proxy_id = SmartProxy.unscoped.joins(:hostnames).where(hostnames: { id: group.puppet_ca_proxy_hostname_id }).try(:first).try(:id)
      end
      if group.puppet_proxy_hostname_id
        group.puppet_proxy_id = SmartProxy.unscoped.joins(:hostnames).where(hostnames: { id: group.puppet_proxy_hostname_id }).try(:first).try(:id)
      end
      group.save!(:validate => false)
    end
    remove_column :hostgroups, :puppet_ca_proxy_hostname_id, :integer
    remove_column :hostgroups, :puppet_proxy_hostname_id, :integer

    drop_table :hostnames_smart_proxies
    drop_table :hostnames

    add_foreign_key "hostgroups", "smart_proxies", :name => "hostgroups_puppet_ca_proxy_id_fk", :column => "puppet_ca_proxy_id"
    add_foreign_key "hostgroups", "smart_proxies", :name => "hostgroups_puppet_proxy_id_fk", :column => "puppet_proxy_id"
    add_foreign_key "hosts", "smart_proxies", :name => "hosts_puppet_ca_proxy_id_fk", :column => "puppet_ca_proxy_id"
    add_foreign_key "hosts", "smart_proxies", :name => "hosts_puppet_proxy_id_fk", :column => "puppet_proxy_id"
  end
end
