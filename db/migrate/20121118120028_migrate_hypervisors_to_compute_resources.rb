class MigrateHypervisorsToComputeResources < ActiveRecord::Migration
  class Hypervisor < ActiveRecord::Base; end

  def up
    return unless Hypervisor.table_exists?

    Hypervisor.all.each do |hypervisor|
      # check if we have the same compute resource already, if we do, skip it.
      next if Foreman::Model::Libvirt.find_by_url hypervisor.uri

      Foreman::Model::Libvirt.create :name        => hypervisor.name,
                                     :url         => hypervisor.uri,
                                     :description => "Automatically migrated from hypervisor #{hypervisor.name} / #{hypervisor.uri}"
    end
    drop_table :hypervisors
  end

  def down
  end
end
