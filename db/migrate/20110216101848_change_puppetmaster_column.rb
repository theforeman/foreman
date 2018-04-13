class ChangePuppetmasterColumn < ActiveRecord::Migration[4.2]
  def up
    # Hosts
    rename_column :hosts, :puppetmaster, :puppetmaster_name
    add_column    :hosts, :puppetproxy_id, :integer

    # Hostgroups
    rename_column :hostgroups, :puppetmaster, :puppetmaster_name
    add_column    :hostgroups, :puppetproxy_id, :integer
  end

  def down
    # Hosts
    remove_column :hosts, :puppetproxy_id
    rename_column :hosts, :puppetmaster_name, :puppetmaster

    # Hostgroups
    remove_column :hostgroups, :puppetproxy_id
    rename_column :hostgroups, :puppetmaster_name, :puppetmaster
  end
end
