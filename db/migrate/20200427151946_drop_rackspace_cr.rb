class DropRackspaceCr < ActiveRecord::Migration[5.2]
  class Foreman::Model::Rackspace < ComputeResource
  end

  def up
    crs = ComputeResource.unscoped.where(type: "Foreman::Model::Rackspace")
    Host.unscoped.where(compute_resource: crs).update_all(compute_resource_id: nil)
    Hostgroup.unscoped.where(compute_resource: crs).update_all(compute_resource_id: nil)
    crs.destroy_all
  end
end
