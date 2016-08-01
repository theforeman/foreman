module Foreman::Model
  class Openstack < ComputeResource
    attr_accessor :tenant, :scheduler_hint_value
    has_one :key_pair, :foreign_key => :compute_resource_id, :dependent => :destroy
    after_create :setup_key_pair
    after_destroy :destroy_key_pair
    delegate :flavors, :to => :client
    delegate :tenants, :to => :client
    delegate :security_groups, :to => :client

    validates :user, :password, :presence => true
    validates :allow_external_network, inclusion: { in: [true, false] }

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
      args[:block_device_mapping_v2] = [ {
        :source_type => "volume",
        :destination_type => "volume",
        :delete_on_termination => "1",
        :uuid => @boot_vol_id,
        :boot_index => "0"
      } ]
    end

    def possible_scheduler_hints
      SEARCHABLE_ACTIONS.collect{|x| x.to_s.camelize }
    end

    def get_server_groups(policy)
      server_groups = client.server_groups.select{ |sg| sg.policies.include?(policy) }
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
      args[:nics].map! {|nic| { 'net_id' => nic } }
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
      associate_by("ip", [vm.floating_ip_address, vm.private_ip_address])
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
      @zones ||= (client.list_zones.body["availabilityZoneInfo"].try(:map){|i| i["zoneName"]} || [])
    end

    private

    def fog_credentials
      { :provider => :openstack,
        :openstack_api_key  => password,
        :openstack_username => user,
        :openstack_auth_url => url,
        :openstack_tenant   => tenant,
        :openstack_identity_endpoint => url }
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

    def setup_key_pair
      key = client.key_pairs.create :name => "foreman-#{id}#{Foreman.uuid}"
      KeyPair.create! :name => key.name, :compute_resource_id => self.id, :secret => key.private_key
    rescue => e
      Foreman::Logging.exception("Failed to generate key pair", e)
      destroy_key_pair
      raise
    end

    def destroy_key_pair
      return unless key_pair
      logger.info "removing OpenStack key #{key_pair.name}"
      key = client.key_pairs.get(key_pair.name)
      key.destroy if key
      key_pair.destroy
      true
    rescue => e
      logger.warn "failed to delete key pair from OpenStack, you might need to cleanup manually : #{e}"
    end

    def vm_instance_defaults
      super.merge(:key_name => key_pair.name)
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
