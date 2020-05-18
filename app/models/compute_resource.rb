class ComputeResource < ApplicationRecord
  audited :except => [:attrs]
  include Taxonomix
  include Encryptable
  include Authorizable
  include Parameterizable::ByIdName
  encrypts :password

  ALLOWED_KEYBOARD_LAYOUTS = %w(ar de-ch es fo fr-ca hu ja mk no pt-br sv da en-gb et fr fr-ch is lt nl pl ru th de en-us fi fr-be hr it lv nl-be pt sl tr)

  validates_lengths_from_database

  serialize :attrs, Hash
  belongs_to :http_proxy

  before_destroy EnsureNotUsedBy.new(:hosts)
  validates :name, :presence => true, :uniqueness => true
  validate :ensure_provider_not_changed, :on => :update
  validates :provider, :presence => true, :inclusion => { :in => proc { providers } }
  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :type, :complete_value => :true
  scoped_search :on => :id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  before_save :sanitize_url
  has_many_hosts
  has_many :hostgroups, :dependent => :nullify
  has_many :images, :dependent => :destroy
  before_validation :set_attributes_hash
  has_many :compute_attributes, :dependent => :destroy
  has_many :compute_profiles, :through => :compute_attributes

  # The DB may contain compute resource from disabled plugins - filter them out here
  scope :live_descendants, -> { where(:type => descendants.map(&:to_s)) unless Rails.env.development? }

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("compute_resources.name")
    end
  }

  graphql_type '::Types::ComputeResource'

  def self.supported_providers
    {
      'Libvirt'   => 'Foreman::Model::Libvirt',
      'Ovirt'     => 'Foreman::Model::Ovirt',
      'EC2'       => 'Foreman::Model::EC2',
      'Vmware'    => 'Foreman::Model::Vmware',
      'Openstack' => 'Foreman::Model::Openstack',
      'GCE'       => 'Foreman::Model::GCE',
    }
  end

  def self.registered_providers
    Foreman::Plugin.all.map(&:compute_resources).each_with_object({}) do |providers, prov_hash|
      providers.each { |provider| prov_hash.update(provider.split('::').last => provider) }
    end
  end

  def self.all_providers
    supported_providers.merge(registered_providers)
  end

  # Providers in Foreman core that have optional installation should override this to check if
  # they are installed. Plugins should not need to override this, as their dependencies should
  # always be present.
  def self.available?
    true
  end

  def self.providers
    supported_providers.merge(registered_providers).select do |provider_name, class_name|
      class_name.constantize.available?
    end
  end

  def self.providers_requiring_url
    _("Libvirt, oVirt and OpenStack")
  end

  def self.provider_class(name)
    all_providers[name]
  end

  # allows to create a specific compute class based on the provider.
  def self.new_provider(args)
    provider = args.delete(:provider)
    raise ::Foreman::Exception.new(N_("must provide a provider")) unless provider
    providers.each do |provider_name, provider_class|
      return provider_class.constantize.new(args) if provider_name.downcase == provider.downcase
    end
    raise ::Foreman::Exception.new N_("unknown provider")
  end

  def capabilities
    []
  end

  def capable?(feature)
    capabilities.include?(feature)
  end

  # attributes that this provider can provide back to the host object
  def provided_attributes
    {:uuid => :identity}
  end

  def test_connection(options = {})
    valid?
  end

  def ping
    test_connection
    errors
  end

  def save_vm(uuid, attr)
    vm = find_vm_by_uuid(uuid)
    vm.attributes.merge!(attr.deep_symbolize_keys)
    vm.save
  end

  def to_label
    "#{name} (#{provider_friendly_name})"
  end

  def connection_options
    http_proxy ? {:proxy => http_proxy.full_url} : {}
  end

  # Override this method to specify provider name
  def self.provider_friendly_name
    name.split('::').last()
  end

  def provider_friendly_name
    self.class.provider_friendly_name
  end

  def host_compute_attrs(host)
    { :name => host.vm_name,
      :provision_method => host.provision_method,
      :firmware_type => host.firmware_type,
      "#{interfaces_attrs_name}_attributes" => host_interfaces_attrs(host) }.with_indifferent_access
  end

  def host_interfaces_attrs(host)
    host.interfaces.select(&:physical?).each.with_index.reduce({}) do |hash, (nic, index)|
      hash.merge(index.to_s => nic.compute_attributes.merge(ip: nic.ip, ip6: nic.ip6))
    end
  end

  def image_param_name
    :image_id
  end

  def interfaces_attrs_name
    :interfaces
  end

  # returns a new fog server instance
  def new_vm(attr = {})
    test_connection
    client.servers.new vm_instance_defaults.merge(attr.to_hash.deep_symbolize_keys) if errors.empty?
  end

  # return fog new interface ( network adapter )
  def new_interface(attr = {})
    client.interfaces.new attr
  end

  # return a list of virtual machines
  def vms(attrs = {})
    client.servers(attrs)
  end

  def supports_vms_pagination?
    false
  end

  def find_vm_by_uuid(uuid)
    client.servers.get(uuid) || raise(ActiveRecord::RecordNotFound)
  end

  def start_vm(uuid)
    find_vm_by_uuid(uuid).start
  end

  def stop_vm(uuid)
    find_vm_by_uuid(uuid).stop
  end

  def create_vm(args = {})
    options = vm_instance_defaults.merge(args.to_hash.deep_symbolize_keys)
    logger.debug("creating VM with the following options: #{options.inspect}")
    client.servers.create options
  end

  def destroy_vm(uuid)
    find_vm_by_uuid(uuid).destroy
  rescue ActiveRecord::RecordNotFound
    # if the VM does not exists, we don't really care.
    true
  end

  def provider
    self[:type].to_s.split('::').last
  end

  def provider=(value)
    if self.class.providers.include? value
      self.type = self.class.provider_class(value)
    else
      self.type = value # this will trigger validation error since value is one of supported_providers
      logger.debug("unknown provider for compute resource")
    end
  end

  def vm_instance_defaults
    ActiveSupport::HashWithIndifferentAccess.new(:name => "foreman_#{Time.now.to_i}")
  end

  def templates(opts = {})
  end

  def template(id, opts = {})
  end

  def update_required?(old_attrs, new_attrs)
    old_attrs.deep_symbolize_keys.merge(new_attrs.deep_symbolize_keys) do |k, old_v, new_v|
      if old_v.is_a?(Hash) && new_v.is_a?(Hash)
        return true if update_required?(old_v, new_v)
      elsif old_v.to_s != new_v.to_s
        Rails.logger.debug "Scheduling compute instance update because #{k} changed it's value from '#{old_v}' (#{old_v.class}) to '#{new_v}' (#{new_v.class})"
        return true
      end
      new_v
    end
    false
  end

  def console(uuid = nil)
    raise ::Foreman::Exception.new(N_("%s console is not supported at this time"), provider_friendly_name)
  end

  # by default, our compute providers do not support updating an existing instance
  def supports_update?
    false
  end

  def storage_domain(storage_domain)
    raise ::Foreman::Exception.new(N_("Not implemented for %s"), provider_friendly_name)
  end

  def storage_pod(storage_pod)
    raise ::Foreman::Exception.new(N_("Not implemented for %s"), provider_friendly_name)
  end

  def available_zones
    raise ::Foreman::Exception.new(N_("Not implemented for %s"), provider_friendly_name)
  end

  def available_images
    []
  end

  def available_virtual_machines
    raise ::Foreman::Exception.new(N_("Not implemented for %s"), provider_friendly_name)
  end

  def available_networks(cluster_id = nil)
    raise ::Foreman::Exception.new(N_("Not implemented for %s"), provider_friendly_name)
  end

  def available_clusters
    raise ::Foreman::Exception.new(N_("Not implemented for %s"), provider_friendly_name)
  end

  def available_folders
    raise ::Foreman::Exception.new(N_("Not implemented for %s"), provider_friendly_name)
  end

  def available_flavors
    raise ::Foreman::Exception.new(N_("Not implemented for %s"), provider_friendly_name)
  end

  def available_resource_pools
    raise ::Foreman::Exception.new(N_("Not implemented for %s"), provider_friendly_name)
  end

  def available_security_groups
    raise ::Foreman::Exception.new(N_("Not implemented for %s"), provider_friendly_name)
  end

  def available_storage_domains(cluster_id = nil)
    raise ::Foreman::Exception.new(N_("Not implemented for %s"), provider_friendly_name)
  end

  def available_storage_pods(cluster_id = nil)
    raise ::Foreman::Exception.new(N_("Not implemented for %s"), provider_friendly_name)
  end

  # if this method is overridden in a provider, new_volume_errors should be also overridden
  # method should return nil in case it can't build new volume because of some misconfiguration or runtime issue
  def new_volume(attr = {})
    raise ::Foreman::Exception.new(N_("Not implemented for %s"), provider_friendly_name)
  end

  # returs an array of translated errors that prevents to build a volume on this provider
  def new_volume_errors
    []
  end

  # this method is overwritten for Libvirt and OVirt
  def editable_network_interfaces?
    networks.any?
  end

  # this method is overwritten for Libvirt and VMware
  def set_console_password?
    false
  end
  alias_method :set_console_password, :set_console_password?

  # this method is overwritten for Libvirt and VMware
  def set_console_password=(setpw)
    attrs[:setpw] = nil
  end

  # this method is overwritten for Libvirt, oVirt & VMWare
  def display_type=(_)
  end

  # this method is overwritten for Libvirt, oVirt & VMWare
  def display_type
    nil
  end

  # this method is overwritten for oVirt
  def keyboard_layout=(_)
  end

  # this method is overwritten for oVirt
  def keyboard_layout
    nil
  end

  def keyboard_layouts
    ALLOWED_KEYBOARD_LAYOUTS
  end

  def compute_profile_for(id)
    compute_attributes.find_by_compute_profile_id(id)
  end

  def compute_profile_attributes_for(id)
    compute_profile_for(id).try(:vm_attrs) || {}
  end

  def vm_compute_attributes_for(uuid)
    vm = find_vm_by_uuid(uuid)
    return {} unless vm
    vm_compute_attributes(vm)
  rescue ActiveRecord::RecordNotFound
    logger.warn("VM with UUID '#{uuid}' not found on #{self}")
    {}
  end

  def vm_compute_attributes(vm)
    vm_attrs = vm.attributes rescue {}
    vm_attrs = vm_attrs.reject { |k, v| k == :id }

    vm_attrs = set_vm_volumes_attributes(vm, vm_attrs)
    vm_attrs = set_vm_interfaces_attributes(vm, vm_attrs)
    vm_attrs
  end

  def vm_ready(vm)
    vm.wait_for { ready? }
  end

  def user_data_supported?
    false
  end

  def image_exists?(image)
    true
  end

  def supports_host_association?
    respond_to?(:associated_host)
  end

  def normalize_vm_attrs(vm_attrs)
    vm_attrs
  end

  protected

  def memory_gb_to_bytes(memory_size)
    memory_size.to_s.gsub(/[^0-9]/, '').to_i * 1.gigabyte
  end

  def to_bool(value)
    ['1', 'true'].include?(value.to_s.downcase) unless value.nil?
  end

  def slice_vm_attributes(vm_attrs, fields)
    fields.inject({}) do |slice, f|
      slice.merge({f => (vm_attrs[f].to_s.empty? ? nil : vm_attrs[f])})
    end
  end

  def client
    raise ::Foreman::Exception.new N_("Not implemented")
  end

  def sanitize_url
    self.url = url.chomp("/") unless url.empty?
  end

  def random_password
    return nil unless set_console_password?
    SecureRandom.hex(8)
  end

  def nested_attributes_for(type, opts)
    return [] unless opts
    opts = opts.to_hash if opts.class == ActionController::Parameters

    opts = opts.dup # duplicate to prevent changing the origin opts.
    opts.delete("new_#{type}") || opts.delete("new_#{type}".to_sym) # delete template
    # convert our options hash into a sorted array (e.g. to preserve nic / disks order)
    opts = opts.sort { |l, r| l[0].to_s.sub('new_', '').to_i <=> r[0].to_s.sub('new_', '').to_i }.map { |e| Hash[e[1]] }
    opts.map do |v|
      if v[:_delete] == '1' && v[:id].blank?
        nil
      else
        v.deep_symbolize_keys # convert to symbols deeper hashes
      end
    end.compact
  end

  def associate_by(name, attributes)
    attributes = Array.wrap(attributes).map { |mac| Net::Validations.normalize_mac(mac) } if name == 'mac'
    Host.authorized(:view_hosts, Host).joins(:primary_interface).
      where(:nics => {:primary => true}).
      where("nics.#{name}" => attributes).
      readonly(false).
      first
  end

  private

  def set_vm_volumes_attributes(vm, vm_attrs)
    if vm.respond_to?(:volumes)
      volumes = vm.volumes || []
      vm_attrs[:volumes_attributes] = Hash[volumes.each_with_index.map { |volume, idx| [idx.to_s, volume.attributes] }]
    end
    vm_attrs
  end

  def set_attributes_hash
    self.attrs ||= {}
  end

  def ensure_provider_not_changed
    errors.add(:provider, _("cannot be changed")) if type_changed?
  end

  def set_vm_interfaces_attributes(_vm, vm_attrs)
    vm_attrs
  end
end
