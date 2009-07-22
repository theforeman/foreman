class CreateHosts < ActiveRecord::Migration
  def self.up
    #TODO: create a migration if puppets database already exists!
    unless Host.table_exists?
      require 'puppet/rails/database/schema'
      Puppet::Rails::Schema.init
      Puppet::Rails.migrate()
    end

    require 'puppet/rails/database/schema'
    Puppet::Rails::Schema.init
    Puppet::Rails.migrate()
    
    add_column :hosts, :mac, :string, :limit => 17, :default => ""
    add_column :hosts, :sp_mac, :string, :limit => 17, :default => ""
    add_column :hosts, :sp_ip, :string, :limit => 15, :default => ""
    add_column :hosts, :sp_name, :string, :default => ""
    add_column :hosts, :root_pass, :string, :limit => 64
    add_column :hosts, :serial, :string, :limit => 12
    add_column :hosts, :puppetmaster, :string
    add_column :hosts, :services, :string

    add_column :hosts, :domain_id, :integer
    add_column :hosts, :architecture_id, :integer
    add_column :hosts, :operatingsystem_id, :integer
    add_column :hosts, :subnet_id, :integer
    add_column :hosts, :sp_subnet_id, :integer
    add_column :hosts, :ptable_id, :integer
    add_column :hosts, :build, :boolean, :default => true
    add_column :hosts, :comment, :text
    add_column :hosts, :disk, :text

    add_column :hosts, :installed_at, :datetime
  end

  def self.down
    drop_table :hosts
  end
end
