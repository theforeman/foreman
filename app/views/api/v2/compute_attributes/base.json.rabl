object @compute_attribute

attributes :id, :name, :compute_resource_id, :compute_resource_name, :provider_friendly_name,
  :compute_profile_id, :compute_profile_name, :vm_attrs
attributes :normalized_vm_attrs => :attributes
