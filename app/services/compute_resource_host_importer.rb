class ComputeResourceHostImporter
  attr_accessor :host, :compute_resource, :vm

  delegate :logger, :to => :Rails

  def initialize(opts = {})
    self.compute_resource = opts.fetch(:compute_resource)
    self.vm = compute_resource.find_vm_by_uuid(opts[:uuid]) if opts[:uuid]
    self.vm ||= opts.fetch(:vm)
    self.host = Host::Managed.new(
      :managed => opts.key?(:managed) ? opts[:managed] : true,
      :build => false,
      :compute_resource => compute_resource,
      :vm => vm
    )
    copy_vm_attributes
    parse_vm_name
    initialize_interfaces
  end

  private

  def copy_vm_attributes
    compute_resource.provided_attributes.each do |foreman_attr, fog_attr|
      value = vm.public_send(fog_attr)
      host.send("#{foreman_attr}=", value)
    end
  end

  def parse_vm_name
    name, domain = vm_name.split('.', 2)
    host.name = name
    return unless Net::Validations.validate_hostname(domain)
    host.domain = Domain.where(:name => domain).first_or_create
  end

  def initialize_interfaces
    vm_interfaces = vm_interface_attributes

    host.interfaces.select(&:physical?).each do |interface|
      vm_interface = vm_interfaces.shift
      return if vm_interface.nil?
      set_nic_compute_attributes(interface, vm_interface)
    end

    vm_interfaces.each do |vm_interface|
      host.interfaces << set_nic_compute_attributes(Nic::Managed.new, vm_interface)
    end
  end

  def set_nic_compute_attributes(interface, vm_interface)
    interface.assign_attributes(vm_interface)
    interface
  end

  def vm_interface_attributes
    vm_attrs = host.compute.attributes
    attr_name = compute_resource.interfaces_attrs_name
    attr_key = "#{attr_name}_attributes"
    vm_attrs.with_indifferent_access[attr_key].try(:values) || []
  end

  def vm_name
    [
      vm.try(:hostname),
      vm.try(:name),
      vm.try(:identity),
    ].detect(&:present?)
  end
end
