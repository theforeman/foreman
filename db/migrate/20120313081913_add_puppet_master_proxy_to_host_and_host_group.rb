class AddPuppetMasterProxyToHostAndHostGroup < ActiveRecord::Migration[4.2]
  class SmartProxy < ApplicationRecord
    has_and_belongs_to_many :features
  end

  def up
    rename_column :hosts, :puppetproxy_id, :puppet_ca_proxy_id
    add_column :hosts, :puppet_proxy_id, :integer
    rename_column :hostgroups, :puppetproxy_id, :puppet_ca_proxy_id
    add_column :hostgroups, :puppet_proxy_id, :integer
    Host.reset_column_information
    Hostgroup.reset_column_information
    ca_proxies = SmartProxy.joins(:features).where(:features => { :name => "Puppet CA" })
    proxies    = SmartProxy.joins(:features).where(:features => { :name => "Puppet" })
    Host.unscoped.select([:id, :puppetmaster_name]).each do |host|
      proxy = nil
      proxies.each { |p| proxy ||= p if p.to_s == host.puppetmaster_name }
      # if we can't figure out our proxy, we just fall back to the CA'
      proxy ||= ca_proxies.first if ca_proxies.any?
      host.update_single_attribute(:puppet_proxy_id, proxy.id) if proxy
    end
    Hostgroup.unscoped.select([:id, :puppetmaster_name]).each do |hg|
      proxy = nil
      proxies.each { |p| proxy ||= p if p.to_s == hg.puppetmaster_name }
      proxy ||= ca_proxies.first if ca_proxies.any?
      hg.update_single_attribute(:puppet_proxy_id, proxy.id) if proxy
    end
    remove_column :hosts, :puppetmaster_name
    remove_column :hostgroups, :puppetmaster_name
  end

  def down
    remove_column :hosts, :puppet_proxy_id
    rename_column :hosts, :puppet_ca_proxy_id, :puppetproxy_id
    remove_column :hostgroups, :puppet_proxy_id
    rename_column :hostgroups, :puppet_ca_proxy_id, :puppetproxy_id
    add_column :hosts, :puppetmaster_name, :string, :limit => 255
    add_column :hostgroups, :puppetmaster_name, :string, :limit => 255
  end
end
