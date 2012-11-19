class MigrateHypervisorsToComputeResources < ActiveRecord::Migration
  class Hypervisor < ActiveRecord::Base; end
  def self.up
    return unless Hypervisor.table_exists?

    Hypervisor.all.each do |hypervisor|
      host = Foreman::Model::Libvirt.find_by_url hypervisor.url
      next if host # this host already exits
      host.name = hypervisor.name
      host.description = "Automaticilly migrated from hypervisor #{hypervisor.name} / #{hypervisor.url}"
      say host.description
      host.save
    end
    drop_table :hypervisors
  end

  def self.down
  end
end
