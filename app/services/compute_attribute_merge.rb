class ComputeAttributeMerge
  def run(host, compute_attrs)
    return if compute_attrs.nil?

    host.compute_attributes ||= {}.with_indifferent_access

    vm_attrs = compute_attrs.vm_attrs
    vm_attrs = vm_attrs.deep_merge(host.compute_attributes)

    host.compute_attributes = vm_attrs
  end
end
