class FakeNic < ActiveRecord::Base
  self.table_name = 'nics'

  def type
    Nic::Managed
  end
end

class FakeHost < ActiveRecord::Base
  self.table_name = 'hosts'

  def type
    Host::Managed
  end
end

class CopyUnmanagedHostsToInterfaces < ActiveRecord::Migration
  def up
    say "Migrating Unmanaged Host interfaces to standalone Interfaces"

    FakeHost.where(:managed => false).each do |host|
      nic = FakeNic.where(:host_id => host.id, :primary => true, :provision => true).first
      if nic.present?
        nic.name = host.name if nic.name.blank?
      else
        nic = FakeNic.new
        nic.host_id = host.id
        nic.name = host.name
        nic.virtual = false
        nic.identifier = host.primary_interface || "eth0"
        nic.managed = host.managed?
        nic.primary = true
        nic.provision = true
        nic.type = 'Nic::Managed'
      end
      nic.save!

      say "  Migrated #{nic.name}-#{nic.identifier} to nics"
    end
  end

  def down
  end
end
