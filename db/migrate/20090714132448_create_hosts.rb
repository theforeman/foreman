class CreateHosts < ActiveRecord::Migration
  def self.up

    # we are only creating the full database if the hosts table doesn't exists, if it does, we assume that store config is already configured
    unless Host.table_exists?
      require 'puppet/rails/database/schema'
      Puppet[:dbadapter]= ActiveRecord::Base.configurations[Rails.env]["adapter"].sub("mysql2", "mysql")
      Puppet::Rails::Schema.init
      Puppet::Rails.migrate()
    end

    add_column :hosts, :mac, :string, :limit => 17, :default => ""
    add_column :hosts, :sp_mac, :string, :limit => 17, :default => ""
    add_column :hosts, :sp_ip, :string, :limit => 15, :default => ""
    add_column :hosts, :sp_name, :string, :default => ""
    add_column :hosts, :root_pass, :string, :limit => 64
    add_column :hosts, :serial, :string, :limit => 12
    add_column :hosts, :puppetmaster, :string
    add_column :hosts, :puppet_status, :integer,  :null => false, :default => 0

    add_column :hosts, :domain_id, :integer
    add_column :hosts, :architecture_id, :integer
    add_column :hosts, :operatingsystem_id, :integer
    add_column :hosts, :environment_id, :integer
    add_column :hosts, :subnet_id, :integer
    add_column :hosts, :sp_subnet_id, :integer
    add_column :hosts, :ptable_id, :integer
    add_column :hosts, :medium_id, :integer
    add_column :hosts, :build, :boolean, :default => true
    add_column :hosts, :comment, :text
    add_column :hosts, :disk, :text

    add_column :hosts, :installed_at, :datetime
  end

  def self.down
    # we are using storeconfigs
    if Puppet.settings.instance_variable_get(:@values)[:puppetmasterd][:storeconfigs]
      remove_columns :hosts, :mac, :sp_mac, :sp_ip, :sp_name, :root_pass, :serial,
        :puppetmaster, :puppet_status, :domain_id, :architecture_id, :operatingsystem_id,
        :environment_id, :subnet_id, :sp_subnet_id, :ptable_id, :hosttype_id,
        :medium_id, :build, :comment, :disk, :installed_at
    else
      drop_table :hosts
    end
  end
end
