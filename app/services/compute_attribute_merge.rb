class ComputeAttributeMerge
  def run(host, compute_attrs)
    return if compute_attrs.nil?

    host.compute_attributes ||= {}.with_indifferent_access

    # Exclude interfaces compute attributes from merge, use InterfaceMerge
    # instead for more precise merging of interfaces
    interface_attrs_key = "#{compute_attrs.compute_resource.interfaces_attrs_name}_attributes"
    vm_attrs = compute_attrs.vm_attrs.except(interface_attrs_key)

    vm_attrs = vm_attrs.deep_merge(host.compute_attributes)

    host.compute_attributes = vm_attrs
  end
end
