class InterfaceMerge
  def run(interfaces, compute_attrs)
    return if compute_attrs.nil?

    vm_interfaces = compute_attrs.vm_interfaces

    # merge with existing
    interfaces.select(&:physical?).each do |nic|
      vm_nic = vm_interfaces.shift
      return if vm_nic.nil?
      merge(nic, vm_nic, compute_attrs)
    end

    # create additional if there are some attributes left
    vm_interfaces.each do |vm_nic|
      interfaces << merge(Nic::Managed.new, vm_nic, compute_attrs)
    end
  end

  private

  def merge(nic, vm_nic, compute_attrs)
    nic.compute_attributes = vm_nic
    nic.compute_attributes['from_profile'] = compute_attrs.compute_profile.name
    nic
  end
end
