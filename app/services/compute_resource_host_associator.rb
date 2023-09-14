class ComputeResourceHostAssociator
  attr_accessor :compute_resource, :hosts, :fail_count

  def initialize(compute_resource)
    @hosts = []
    @fail_count = 0
    self.compute_resource = compute_resource
  end

  def associate_hosts(vms = compute_resource.vms(:eager_loading => true))
    vms.each do |vm|
      if Host.for_vm(compute_resource, vm).empty?
        associate_vm(vm)
      end
    end
  end

  def associate_host(host)
    vm = compute_resource.associated_vm(host)
    if vm.present?
      host.associate!(compute_resource, vm)
      @hosts << host
    end
  rescue StandardError => e
    @fail_count += 1
    Foreman::Logging.exception("Could not associate host #{host}", e)
  end

  private

  def associate_vm(vm)
    host = compute_resource.associated_host(vm)
    if host.present?
      host.associate!(compute_resource, vm)
      @hosts << host
    end
  rescue StandardError => e
    @fail_count += 1
    Foreman::Logging.exception("Could not associate VM #{vm}", e)
  end
end
