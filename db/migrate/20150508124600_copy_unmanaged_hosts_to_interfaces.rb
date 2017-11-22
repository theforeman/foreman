class FakeNic < ApplicationRecord
  self.table_name = 'nics'

  def type
    Nic::Managed
  end
end

class FakeHost < ApplicationRecord
  self.table_name = 'hosts'

  def type
    Host::Managed
  end
end

class CopyUnmanagedHostsToInterfaces < ActiveRecord::Migration[4.2]
  def up
    say "Migrating Unmanaged Host interfaces to standalone Interfaces"

    FakeHost.where(:managed => false).each do |host|
      say "  ... migrating #{host.name}"
      nic = FakeNic.where(:host_id => host.id, :primary => true, :provision => true).first
      if nic.present?
        nic.name = host.name if nic.name.blank?
        # we ignore validation errors on existing primary interface
        unless nic.valid?
          say "  Host #{host.name} has invalid interface with id `#{nic.id}` and identifier `#{nic.identifier}`, you have to fix it manually through API"
          nic.errors.each { |a, m| say "    * #{a} #{m}" }
          say "    following command is an example of how to modify the interface IP through API using curl"
          say "      curl -X PUT -H 'Content-Type: application/json' --user 'admin:$adminpw' -d '{\"interface\":{\"ip\":\"$real_ip\"}}' 'https://$foreman_url/api/v2/hosts/#{host.name}/interfaces/#{nic.id}'"
        end
        nic.save(:validate => false)
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
        nic.save!
      end

      say "  ... migrated #{nic.name}-#{nic.identifier} to nics"
      say ''
    end
  end

  def down
  end
end
