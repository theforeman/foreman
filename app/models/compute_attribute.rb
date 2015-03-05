class ComputeAttribute < ActiveRecord::Base
  attr_accessible :compute_profile_id, :compute_resource_id, :vm_attrs
  audited :associated_with => :compute_profile

  belongs_to :compute_resource
  belongs_to :compute_profile

  validates :compute_profile_id, :presence => true, :uniqueness => {:scope => :compute_resource_id}
  validates :compute_resource_id, :presence => true, :uniqueness => {:scope => :compute_profile_id}

  serialize :vm_attrs, Hash
  before_save :update_name

  def method_missing(method, *args, &block)
    return vm_attrs["#{method}"] if vm_attrs.keys.include?(method.to_s)
    raise Foreman::Exception.new(N_('%s is an unknown attribute'), method)
  end

  def vm_interfaces
    attribute_values(compute_resource.interfaces_attrs_name)
  end

  def new_vm
    compute_resource.new_vm(vm_attrs) if vm_attrs
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
    attr_key = "#{attr_name}_attributes"
    if vm_attrs[attr_key]
      vm_attrs[attr_key].select { |k,v| k.to_s != "new_#{attr_name}" }.values
    else
      []
    end
  end
end
