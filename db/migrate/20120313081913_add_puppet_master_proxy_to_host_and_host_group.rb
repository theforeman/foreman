class AddPuppetMasterProxyToHostAndHostGroup < ActiveRecord::Migration[4.2]
  def up
    rename_column :hosts, :puppetproxy_id, :puppet_ca_proxy_id
    add_column :hosts, :puppet_proxy_id, :integer
    rename_column :hostgroups, :puppetproxy_id, :puppet_ca_proxy_id
    add_column :hostgroups, :puppet_proxy_id, :integer

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
