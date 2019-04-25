class ComputeResourceHostAssociator
  attr_accessor :compute_resource, :hosts, :fail_count

  def initialize(compute_resource)
    @hosts = []
    @fail_count = 0
    self.compute_resource = compute_resource
  end

  def associate_hosts
    compute_resource.vms(:eager_loading => true).each do |vm|
      if Host.for_vm(compute_resource, vm).empty?
        associate_vm(vm)
      end
    end
  end

  private

  def associate_vm(vm)
    host = compute_resource.associated_host(vm)
    datacenter = compute_resource.uuid
    vm_datacenter = vm.datacenter
    if host.present? && vm_datacenter == datacenter
        host.associate!(compute_resource, vm)
        @hosts << host
      end
    end
  rescue StandardError => e
    @fail_count += 1
    Foreman::Logging.exception("Could not associate VM #{vm}", e)
  end
end
