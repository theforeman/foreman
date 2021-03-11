class Compute
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Dirty

  attr_accessor :compute_resource, :host

  attribute :uuid, :string
  attribute :name, :string, default: -> { "foreman_#{Time.now.to_i}" }

  def initialize(*attrs)
    super
    uuid ||= host.uuid
    @attrs_loaded = false
    raise 'host and compute_resource need to be set for Compute' unless host && compute_resource
  end

  def vm
    @vm ||= persisted? ? find_vm : compute_resource.new_vm(attributes)
  end

  def persisted?
    !uuid.nil?
  end

  def save
    @attrs_loaded = false
    persist_vm
  end

  def vm_name
    Setting[:use_shortname_for_vms] ? host.shortname : host.name
  end

  def attributes
    return super if @attrs_loaded
    loaded = load_vm_attributes.merge(super)
    self.attributes = loaded
    loaded
  end

  protected

  def find_vm
    compute_resource.find_vm_by_uuid(uuid) || raise(ActiveRecord::RecordNotFound.new(nil, Compute, uuid))
  end

  def persist_vm
    persisted? ? create_vm : update_vm
  end

  def create_vm
    compute_resource.create_vm(attributes.merge(host_create_attributes))
  end

  def save_vm
    compute_resource.save_vm(uuid, attributes)
  end

  # Loads persisted vm attributes
  def load_vm_attributes
    @attrs_loaded = true
    return {} unless persisted?
    compute_resource.vm_compute_attributes(vm)
  end

  # This method defines initial VM attributes
  def host_create_attributes
    {
      name: vm_name,
      provision_method: host.provision_method,
      firmware_type: host.firmware_type,
      "#{compute_resource.interfaces_attrs_name}_attributes" => host_interfaces_create_attributes }.with_indifferent_access
    }
  end

  def host_interfaces_create_attributes
    host.interfaces.select(&:physical?).each.with_index.reduce({}) do |hash, (nic, index)|
      hash.merge(index.to_s => nic.compute_attributes.merge(ip: nic.ip, ip6: nic.ip6))
    end
  end
end
