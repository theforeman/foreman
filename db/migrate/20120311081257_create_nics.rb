class CreateNics < ActiveRecord::Migration
  class Host < ActiveRecord::Base; end
  def self.up
    create_table :nics do |t|
      t.string :mac
      t.string :ip
      t.string :type
      t.string :name
      t.references :host
      t.references :subnet
      t.references :domain
      t.text :attrs

      t.timestamps
    end

    add_index :nics, [:type], :name => 'index_by_type'
    add_index :nics, [:host_id], :name => 'index_by_host'
    add_index :nics, [:type, :id], :name => 'index_by_type_and_id'

    Host.where(["sp_mac <> ? and sp_ip <> ?", "", ""]).each do |host|
      begin
        sp_ip  = host.read_attribute(:sp_ip)
        sp_mac = host.read_attribute(:sp_mac)
          Nic::BMC.create! :host_id => host.id, :mac => sp_mac, :ip => sp_ip, :subnet_id => host.read_attribute(:sp_subnet_id),
            :name => host.read_attribute(:sp_name), :priority => 1
          say "created BMC interface for #{host}"
      rescue => e
        say "failed to import nics for #{host} : #{e}"
      end
    end

    remove_columns :hosts, :sp_mac, :sp_ip, :sp_name, :sp_subnet_id
    #   TODO: fix this stuff in search
  end

  def self.down
    add_column :hosts, :sp_mac, :string, :limit => 17, :default => ""
    add_column :hosts, :sp_ip, :string, :limit => 15, :default => ""
    add_column :hosts, :sp_name, :string, :default => ""
    add_column :hosts, :sp_subnet_id, :integer

    Nic::BMC.all.each do |bmc|
      if bmc.host_id
        bmc.host.update_attributes(:sp_mac => bmc.mac, :sp_ip => bmc.ip, :sp_name => bmc.name, :sp_subnet_id => bmc.subnet_id)
      end
    end
    drop_table :nics
  end
end
