class ComputeAttribute < ApplicationRecord
  audited :associated_with => :compute_profile

  belongs_to :compute_resource
  belongs_to :compute_profile

  validates :compute_profile_id, :presence => true, :uniqueness => {:scope => :compute_resource_id}
  validates :compute_resource_id, :presence => true, :uniqueness => {:scope => :compute_profile_id}

  serialize :vm_attrs, Hash
  before_save :update_name

  delegate :provider_friendly_name, :to => :compute_resource
  scoped_search :on => [:name], :complete_value => true
  scoped_search :on => :id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER

  scoped_search :relation => :compute_resource, :on => :name, :rename => :compute_resource, :complete_value => true
  scoped_search :relation => :compute_profile, :on => :name, :rename => :compute_profile, :complete_value => true

  def method_missing(method, *args, &block)
    method = method.to_s
    return super if method[-1] == "="
    return super if method == 'vm_attrs'

    if vm_attrs.has_key?(method)
      vm_attrs[method]
    else
      raise Foreman::Exception.new(N_('%s is an unknown attribute'), method)
    end
  end

  def respond_to_missing?(method, include_private = false)
    vm_attrs.has_key?(method.to_s) || super
  end

  def normalized_vm_attrs
    compute_resource.normalize_vm_attrs(vm_attrs)
  end

  def normalized_new_vm_attrs(new_vm_attrs)
    compute_resource.normalize_vm_attrs(new_vm_attrs)
  end

  def vm_interfaces
    attribute_values(compute_resource.interfaces_attrs_name)
  end

  def new_vm
    compute_resource.new_vm(vm_attrs.dup) if vm_attrs
  end

  def pretty_vm_attrs
    # vm_description is defined in FogExtensions for each compute resource
    @pretty_vm_attrs ||= new_vm.try(:vm_description)
  end

  private

  def update_name
    self.name = pretty_vm_attrs if pretty_vm_attrs.present?
  end

  def attribute_values(attr_name)
    attrs = vm_attrs["#{attr_name}_attributes"]
    (attrs.is_a?(Array) ? attrs : attrs.try(:values)) || []
  end
end
