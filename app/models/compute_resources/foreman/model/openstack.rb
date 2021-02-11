module Foreman::Model
  class Openstack < ComputeResource
    include KeyPairComputeResource
    attr_accessor :scheduler_hint_value
    delegate :flavors, :to => :client
    delegate :security_groups, :to => :client

    validates :url, :format => { :with => URI::DEFAULT_PARSER.make_regexp }, :presence => true
    validate :url_contains_version
    validates :user, :password, :presence => true
    validates :allow_external_network, inclusion: { in: [true, false] }
    validates :domain, :format => { :with => /\A\S+\z/ }, :allow_blank => true

    alias_method :available_flavors, :flavors

    SEARCHABLE_ACTIONS = [:server_group_anti_affinity, :server_group_affinity, :raw]

    def provided_attributes
      super.merge({ :ip => :floating_ip_address })
    end

    def self.available?
      Fog::Compute.providers.include?(:openstack)
    end

    def self.model_name
      ComputeResource.model_name
    end

    def image_param_name
      :image_ref
    end

    def capabilities
      [:image]
    end

    def tenant
      attrs[:tenant]
    end

    def tenant=(name)
      attrs[:tenant] = name
    end

    def project_domain_id
      attrs[:project_domain_id]
    end

    def project_domain_id=(domain)
      attrs[:project_domain_id] = domain
    end

    def project_domain_name
      attrs[:project_domain_name]
    end

    def project_domain_name=(domain)
      attrs[:project_domain_name] = domain
    end

    def tenants
      if identity_version == 3
        user_id = identity_client.current_user_id
        identity_client.list_user_projects(user_id).body["projects"].map { |p| Fog::OpenStack::Identity::V3::Project.new(p) }
      else
        identity_client.tenants
      end
    end

    def identity_version
      return 3 if url =~ /\/v3/
      return 2 if url =~ /\/v2/
      0
    end

    def url_contains_version
      errors.add(:url, _("must end with /v2 or /v3")) if identity_version == 0
    end

    def allow_external_network
      Foreman::Cast.to_bool(attrs[:allow_external_network])
    end

    def allow_external_network=(enabled)
      attrs[:allow_external_network] = Foreman::Cast.to_bool(enabled)
    end

    def test_connection(options = {})
      super
      errors[:user].empty? && errors[:password] && tenants
    rescue => e
      errors[:base] << e.message
    end

    def available_images
      client.images.select { |image| image.status.downcase == 'active' }
    end

    def address_pools
      client.addresses.get_address_pools.map { |p| p["name"] }
    end

    def internal_networks
      return {} if network_client.nil?
      allow_external_network ? network_client.networks.all : network_client.networks.all.select { |net| !net.router_external }
    end

    def image_size(image_id)
      client.get_image_details(image_id).body['image']['minDisk']
    end

    def boot_from_volume(args = {})
      vm_name = args[:name]
      args[:size_gb] = image_size(args[:image_ref]) if args[:size_gb].blank?
      volume_name = "#{vm_name}-vol0"
      boot_vol = volume_client.volumes.create(
        :name => volume_name, # Name attribute in OpenStack volumes API v2
        :display_name => volume_name, # Name attribute in API v1
        :volumeType => "Volume",
        :size => args[:size_gb],
        :imageRef => args[:image_ref])
      @boot_vol_id = boot_vol.id.tr('"', '')
      boot_vol.wait_for { status == 'available' }
      args[:block_device_mapping_v2] = [{
        :source_type => "volume",
        :destination_type => "volume",
        :delete_on_termination => "1",
        :uuid => @boot_vol_id,
        :boot_index => "0",
      }]
    end

    def possible_scheduler_hints
      SEARCHABLE_ACTIONS.collect { |x| x.to_s.camelize }
    end

    def get_server_groups(policy)
      server_groups = client.server_groups.select { |sg| sg.policies.include?(policy) }
      errors.add(:scheduler_hint_value, _("No matching server groups found")) if server_groups.empty?
      server_groups
    end

    def format_scheduler_hint_filter(args = {})
      raise ::Foreman::Exception.new(N_('Hint data is missing')) if args[:scheduler_hint_data].nil?
      name = args.delete(:scheduler_hint_filter).underscore.to_sym
      data = args.delete(:scheduler_hint_data)
      filter = {}
      case name
        when :server_group_anti_affinity, :server_group_affinity
          filter[:group] = data[:scheduler_hint_value]
        when :raw
          filter = JSON.parse(data[:scheduler_hint_value])
      end
      args[:os_scheduler_hints] = filter
    end

    def create_vm(args = {})
      boot_from_volume(args) if Foreman::Cast.to_bool(args[:boot_from_volume])
      network = args.delete(:network)
      # fix internal network format for fog.
      args[:nics].delete_if(&:blank?)
      args[:nics].map! { |nic| nic.is_a?(String) ? { 'net_id' => nic } : nic }
      args[:security_groups].delete_if(&:blank?) if args[:security_groups].present?
      format_scheduler_hint_filter(args) if args[:scheduler_hint_filter].present?
      vm = super(args)
      if network.present?
        address = allocate_address(network)
        assign_floating_ip(address, vm)
      end
      vm
    rescue => e
      message = JSON.parse(e.response.body)['badRequest']['message'] rescue (e.to_s)
      logger.warn "failed to create vm: #{message}"
      destroy_vm vm.id if vm
      volume_client.volumes.delete(@boot_vol_id) if args[:boot_from_volume]
      raise message
    end

    def vm_ready(vm)
      vm.wait_for { ready? || failed? }
      raise Foreman::Exception.new(N_("Failed to deploy vm %{name}, fault: %{e}"), { :name => vm.name, :e => vm.fault['message'] }) if vm.failed?
    end

    def destroy_vm(uuid)
      vm           = find_vm_by_uuid(uuid)
      floating_ips = vm.all_addresses
      floating_ips.each do |address|
        client.disassociate_address(uuid, address['ip']) rescue true
        client.release_address(address['id']) rescue true
      end
      super(uuid)
    rescue ActiveRecord::RecordNotFound
      # if the VM does not exists, we don't really care.
      true
    end

    def console(uuid)
      vm = find_vm_by_uuid(uuid)
      vm.console.body.merge({'timestamp' => Time.now.utc})
    end

    def associated_host(vm)
      associate_by("ip", [vm.floating_ip_address, vm.private_ip_address].compact)
    end

    def flavor_name(flavor_ref)
      client.flavors.get(flavor_ref).try(:name)
    end

    def self.provider_friendly_name
      "OpenStack"
    end

    def user_data_supported?
      true
    end

    def zones
      @zones ||= (client.list_zones.body["availabilityZoneInfo"].try(:map) { |i| i["zoneName"] } || [])
    end

    def normalize_vm_attrs(vm_attrs)
      normalized = slice_vm_attributes(vm_attrs, ['availability_zone', 'tenant_id', 'scheduler_hint_filter'])

      normalized['flavor_id'] = vm_attrs['flavor_ref']
      normalized['flavor_name'] = flavors.detect { |t| t.id == normalized['flavor_id'] }.try(:name)
      normalized['tenant_name'] = tenants.detect { |t| t.id == normalized['tenant_id'] }.try(:name)

      security_group = vm_attrs['security_groups']
      normalized['security_group_name'] = security_group.empty? ? nil : security_group
      normalized['security_group_id'] = security_groups.detect { |t| t.name == security_group }.try(:id)

      floating_ip_network = vm_attrs['network']
      normalized['floating_ip_network'] = floating_ip_network.empty? ? nil : floating_ip_network

      normalized['boot_from_volume'] = to_bool(vm_attrs['boot_from_volume'])

      boot_volume_size = memory_gb_to_bytes(vm_attrs['size_gb'])
      if (boot_volume_size == 0)
        normalized['boot_volume_size'] = nil
      else
        normalized['boot_volume_size'] = boot_volume_size.to_s
      end

      nics_ids = vm_attrs['nics'] || {}
      nics_ids = nics_ids.select { |nic_id| nic_id != '' }
      normalized['interfaces_attributes'] = nics_ids.map.with_index do |nic_id, idx|
        [idx.to_s, {
          'id' => nic_id,
          'name' => internal_networks.detect { |n| n.id == nic_id }.try(:name),
        }]
      end.to_h

      normalized['image_id'] = vm_attrs['image_ref']
      normalized['image_name'] = images.find_by(:uuid => normalized['image_id']).try(:name)

      normalized
    end

    private

    def url_for_fog
      u = URI.parse(url)
      "#{u.scheme}://#{u.host}:#{u.port}"
    end

    def fog_credentials
      { :provider           => :openstack,
        :openstack_api_key  => password,
        :openstack_username => user,
        :openstack_auth_url => url_for_fog,
        :openstack_identity_endpoint => url_for_fog,
        :openstack_endpoint_type => 'publicURL',
      }.tap do |h|
        if tenant.present?
          if identity_version == 2
            h[:openstack_tenant] = tenant
          else
            h[:openstack_project_name] = tenant
          end
        end
        h[:openstack_user_domain] = domain if domain.present?
        h[:openstack_domain_id] = project_domain_id if project_domain_id.present?
        h[:openstack_domain_name] = project_domain_name if project_domain_name.present?
        h[:openstack_identity_api_version] = 'v2.0' if identity_version == 2
        logger.debug { "OpenStack fog credentials: " + h.dup.delete_if { |key, value| key == :openstack_api_key }.to_s }
        h
      end
    end

    def identity_client
      @identity_client ||= ::Fog::Identity.new(fog_credentials.except!(:openstack_identity_endpoint))
    end

    def client
      @client ||= ::Fog::Compute.new(fog_credentials)
    end

    def network_client
      @network_client ||= ::Fog::Network.new(fog_credentials)
    rescue
      @network_client = nil
    end

    def volume_client
      @volume_client ||= ::Fog::Volume.new(fog_credentials)
    end

    def vm_instance_defaults
      super.merge(:key_name => key_pair.try(:name), :metadata => {})
    end

    def assign_floating_ip(address, vm)
      return unless address.status == 200

      # we can't assign floating IP's before we get a private IP.
      vm.wait_for { !addresses.empty? }
      floating_ip = address.body["floating_ip"]["ip"].to_s
      logger.debug("assigning #{floating_ip} to #{vm.name}")
      begin
        vm.associate_address(floating_ip)
      rescue => e
        logger.warn "failed to assign #{floating_ip} to #{vm.name}: #{e}"
        client.disassociate_address(floating_ip)
      end
    end

    def allocate_address(network)
      logger.debug "requesting floating ip address for #{network}"
      client.allocate_address(network)
    rescue => e
      logger.warn "failed to allocate ip address for network #{network}: #{e}"
      raise e
    end
  end
end
