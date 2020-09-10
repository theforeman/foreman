class CreateNics < ActiveRecord::Migration[4.2]
  def up
    create_table :nics do |t|
      t.string :mac, :limit => 255
      t.string :ip, :limit => 255
      t.string :type, :limit => 255
      t.string :name, :limit => 255
      t.references :host
      t.references :subnet
      t.references :domain
      t.text :attrs

      t.timestamps null: true
    end

    add_index :nics, [:type], :name => 'index_by_type'
    add_index :nics, [:host_id], :name => 'index_by_host'
    add_index :nics, [:type, :id], :name => 'index_by_type_and_id'

    Host.unscoped.where(["sp_mac <> ? and sp_ip <> ?", "", ""]).each do |host|
      nic = Nic::BMC.new(:host_id   => host.id, :host => host,
                         :mac       => host.read_attribute(:sp_mac),
                         :ip        => host.read_attribute(:sp_ip),
                         :subnet_id => host.read_attribute(:sp_subnet_id),
                         :provider  => Nic::BMC::PROVIDERS.first,
                         :name      => host.read_attribute(:sp_name))
      # it makes no sense to fire validations here, as that would also trigger
      # the queue, potentially adding new dhcp records
      # since the data is already coming from the DB,
      # we assume it has been validated before.
      nic.save(:validate => false)
    end

    remove_columns :hosts, :sp_mac, :sp_ip, :sp_name, :sp_subnet_id
  end

  def down
    add_column :hosts, :sp_mac, :string, :limit => 17, :default => ""
    add_column :hosts, :sp_ip, :string, :limit => 15, :default => ""
    add_column :hosts, :sp_name, :string, :limit => 255, :default => ""
    add_column :hosts, :sp_subnet_id, :integer

    Nic::BMC.all.each do |bmc|
      if bmc.host_id
        bmc.host.update(:sp_mac => bmc.mac, :sp_ip => bmc.ip, :sp_name => bmc.name, :sp_subnet_id => bmc.subnet_id)
      end
    end
    drop_table :nics
  end
end
