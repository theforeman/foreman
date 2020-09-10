class FakeNic < ApplicationRecord
  self.table_name = 'nics'

  def type
    Nic::Managed
  end
end

class FakeHost < ApplicationRecord
  self.table_name = 'hosts'
end

class MoveHostNicsToInterfaces < ActiveRecord::Migration[4.2]
  def up
    add_column :nics, :primary, :boolean, :default => false
    add_column :nics, :provision, :boolean, :default => false

    say "Migrating Host interfaces to standalone Interfaces"

    Host::Managed.all.each do |host|
      nic = FakeNic.new
      nic.host_id = host.id
      nic.name = host.name
      nic.mac = host.attributes.with_indifferent_access[:mac]
      nic.ip = host.attributes.with_indifferent_access[:ip]
      nic.subnet_id = host.attributes.with_indifferent_access[:subnet_id]
      nic.domain_id = host.attributes.with_indifferent_access[:domain_id]
      nic.virtual = false
      nic.identifier = host.attributes.with_indifferent_access[:primary_interface] || 'eth0'
      nic.managed = host.attributes.with_indifferent_access[:managed]
      nic.primary = true
      nic.provision = true
      nic.type = 'Nic::Managed'
      nic.save!

      say "  Migrated #{nic.name}-#{nic.identifier} to nics"
    end

    remove_column :hosts, :ip
    remove_column :hosts, :mac
    remove_column :hosts, :primary_interface
    remove_foreign_key 'hosts', :name => 'hosts_subnet_id_fk'
    remove_column :hosts, :subnet_id
    remove_foreign_key 'hosts', :name => 'hosts_domain_id_fk'
    remove_column :hosts, :domain_id
  end

  def down
    add_column :hosts, :ip, :string, :limit => 255
    add_column :hosts, :mac, :string, :default => '', :limit => 255
    add_column :hosts, :primary_interface, :string, :limit => 255
    add_column :hosts, :subnet_id, :integer
    add_foreign_key 'hosts', 'subnets', :name => 'hosts_subnet_id_fk'
    add_column :hosts, :domain_id, :integer
    add_foreign_key 'hosts', 'subnets', :name => 'hosts_domain_id_fk'

    say "Migrating Interfaces to Host interfaces"
    FakeHost.reset_column_information
    FakeHost.all.each do |host|
      host = host.becomes(FakeHost)
      raise ActiveRecord::IrreversibleMigration if FakeNic.where(:primary => true, :provision => false).any?
      raise ActiveRecord::IrreversibleMigration if FakeNic.where(:primary => false, :provision => true).any?
      nic = FakeNic.where(:host_id => host.id).where(:primary => true, :provision => true).first
      host.mac = nic.mac
      host.ip = nic.ip
      host.subnet_id = nic.subnet_id
      host.domain_id = nic.domain_id
      host.primary_interface = nic.identifier
      host.type = 'Host::Managed'
      host.save!
      nic.destroy
    end

    remove_column :nics, :primary
    remove_column :nics, :provision
  end
end
