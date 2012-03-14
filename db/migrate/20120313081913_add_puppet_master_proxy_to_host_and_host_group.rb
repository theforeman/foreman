class AddPuppetMasterProxyToHostAndHostGroup < ActiveRecord::Migration
  def self.up
    rename_column :hosts, :puppetproxy_id, :puppet_ca_proxy_id
    add_column :hosts, :puppet_proxy_id, :integer
    rename_column :hostgroups, :puppetproxy_id, :puppet_ca_proxy_id
    add_column :hostgroups, :puppet_proxy_id, :integer
    Host.reset_column_information
    Hostgroup.reset_column_information
    proxies = SmartProxy.joins(:features).where(:features => { :name => "Puppet" })
    if proxies.any?
      Host.select([:id, :puppetmaster_name]).each do |host|
        proxies.each { |p| host.puppet_proxy ||= p if p.to_s == host.puppetmaster_name }
      end
      Hostgroup.select([:id, :puppetmaster_name]).each do |hg|
        proxies.each { |p| hg.puppet_proxy ||= p if p.to_s == hg.puppetmaster_name }
      end
    end
    remove_column :hosts, :puppetmaster_name
    remove_column :hostgroups, :puppetmaster_name
  end

  def self.down
    remove_column :hosts, :puppet_proxy_id
    rename_column :hosts, :puppet_ca_proxy_id, :puppetproxy_id
    remove_column :hostgroups, :puppet_proxy_id
    rename_column :hostgroups, :puppet_ca_proxy_id, :puppetproxy_id
    add_column :hosts, :puppetmaster_name, :string
    add_column :hostgroups, :puppetmaster_name, :string
  end

end
