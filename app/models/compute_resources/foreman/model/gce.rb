module Foreman::Model
  class GCE < ComputeResource
    has_one :key_pair, :foreign_key => :compute_resource_id, :dependent => :destroy
    before_create :setup_key_pair
    validates :key_path, :project, :email, :zone, :presence => true
    validate :ensure_attributes_and_values

    def self.available?
      Fog::Compute.providers.include?(:google)
    end

    def to_label
      "#{name} (#{zone}-#{provider_friendly_name})"
    end

    def capabilities
      [:image, :new_volume]
    end

    def project
      attrs[:project]
    end

    def project=(name)
      attrs[:project] = name
    end

    def key_path
      attrs[:key_path]
    end

    def key_path=(name)
      attrs[:key_path] = name
    end

    def email
      attrs[:email]
    end

    def email=(email)
      attrs[:email] = email
    end

    def provided_attributes
      super.merge({ :ip => :vm_ip_address })
    end

    def zones
      client.list_zones.items.map(&:name)
    end
    alias_method :available_zones, :zones

    def networks
      client.list_networks.items.map(&:name)
    end

    def available_networks(cluster_id = nil)
      client.list_networks.items
    end

    def machine_types
      client.list_machine_types(zone).items
    end
    alias_method :available_flavors, :machine_types

    def disks
      client.list_disks(zone).items.map(&:name)
    end

    def zone
      url
    end

    def zone=(zone)
      self.url = zone
    end

    def new_vm(args = {})
      # convert rails nested_attributes into a plain hash
      [:volumes].each do |collection|
        nested_attrs = args.delete("#{collection}_attributes".to_sym)
        args[collection] = nested_attributes_for(collection, nested_attrs.deep_symbolize_keys) if nested_attrs
      end

      # Dots are not allowed in names
      args[:name] = args[:name].parameterize if args[:name].present?

      # GCE network interfaces cannot be defined though Foreman yet
      if args[:network]
        args[:network_interfaces] = [{ :network => construct_network(args[:network]) }]
        args.except!(:network)
      end

      if to_bool(args[:associate_external_ip])
        args[:network_interfaces] = construct_network_interfaces(args[:network_interfaces])
      end

      # Note - GCE only supports cloud-init for Container Optimized images and
      # for custom images with cloud-init setup
      if (user_data = args.delete(:user_data)).present?
        args[:metadata] = { :items => [{ :key => 'user-data', :value => user_data }]}
      end

      if args[:volumes].present?
        if args[:image_id].to_i > 0
          image = client.images.find { |i| i.id == args[:image_id].to_i }
          if image.nil?
            raise ::Foreman::Exception.new(N_("selected image does not exist"))
          end
          args[:volumes].first[:source_image] = image.name
        end
        args[:disks] = []
        args[:volumes].each_with_index do |vol_args, i|
          args[:disks] << new_volume(vol_args.merge(:name => "#{args[:name]}-disk#{i + 1}"))
        end
      end
      super(args)
    end

    def create_vm(args = {})
      new_vm(args)
      create_volumes(args)

      username = images.find_by(:uuid => args[:image_id]).try(:username)
      ssh = { :username => username, :public_key => "#{key_pair.public} #{username}" }
      args.merge!(ssh)

      vm = client.servers.create vm_options(args)
      vm.disks.each { |disk| vm.set_disk_auto_delete(true, disk[:device_name]) }
      vm
    rescue Fog::Errors::Error => e
      args[:disks].find_all(&:status).map(&:destroy) if args[:disks].present?
      Foreman::Logging.exception("Unhandled GCE error", e)
      raise e
    end

    def vm_options(args)
      options = vm_instance_defaults.merge(args.to_hash.deep_symbolize_keys)

      # deep_symbolize_keys required for :network_interfaces,:metadata
      # fog-google processes these keys & creates objects of respective
      # classes from ::Google::Apis::ComputeV1
      server_optns = options.slice!(:network_interfaces, :metadata)

      # HashWithIndifferentAccess won't work here.
      # server_optns.symbolize_keys required as ::Google::Apis::ComputeV1 classes
      # only accepts keyword arguments while initializing instance.
      options.to_hash.deep_symbolize_keys.merge(server_optns.symbolize_keys)
    end

    def create_volumes(args)
      args[:disks].map(&:save)
      args[:disks].each { |disk| disk.wait_for { disk.ready? } }
    end

    def available_images
      images_list = client.images.current
      if image_families_to_filter.any?
        regexp = Setting.convert_array_to_regexp(image_families_to_filter, prefix: '', suffix: '')
        images_list.select! { |img| img.family&.match(regexp) }
      end
      images_list
    end

    def image_families_to_filter
      self.class.image_families_to_filter
    end

    def self.image_families_to_filter
      @image_families_to_filter ||= []
    end

    # Becomes easy to filter the images list from Google Compute Engine
    # Register an image family using this method to filter list
    # Example - 'rhel', 'centos'
    def self.register_family_for_image_filter(family)
      image_families_to_filter << family
      image_families_to_filter.uniq!
    end

    def self.model_name
      ComputeResource.model_name
    end

    def setup_key_pair
      require 'sshkey'
      name = "foreman-#{id}#{Foreman.uuid}"
      key  = ::SSHKey.generate
      build_key_pair :name => name, :secret => key.private_key, :public => key.ssh_public_key
    end

    def test_connection(options = {})
      super
      errors[:user].empty? && errors[:password].empty? && zones
    rescue => e
      errors[:base] << e.message
    end

    def self.provider_friendly_name
      "Google"
    end

    def interfaces_attrs_name
      :network_interfaces
    end

    def new_volume(attrs = { })
      args = {
        :size_gb   => (attrs[:size_gb] || 10).to_i,
        :zone_name => zone,
      }.merge(attrs)
      client.disks.new(args)
    end

    def normalize_vm_attrs(vm_attrs)
      normalized = slice_vm_attributes(vm_attrs, ['image_id', 'machine_type', 'network'])
      normalized['associate_external_ip'] = to_bool(vm_attrs['associate_external_ip'])
      normalized['image_name'] = images.find_by(:uuid => vm_attrs['image_id']).try(:name)

      volume_attrs = vm_attrs['volumes_attributes'] || {}
      normalized['volumes_attributes'] = volume_attrs.each_with_object({}) do |(key, vol), volumes|
        volumes[key] = { 'size' => memory_gb_to_bytes(vol['size_gb']).to_s }
      end

      normalized
    end

    def user_data_supported?
      true
    end

    def console(uuid)
      vm = find_vm_by_uuid(uuid)
      if vm.ready?
        {
          'output' =>  vm.serial_port_output, 'timestamp' => Time.now.utc
        }.merge(:type => 'log', :name => vm.name)
      else
        raise ::Foreman::Exception.new(N_("console is not available at this time because the instance is powered off"))
      end
    end

    def associated_host(vm)
      associate_by("ip", [vm.public_ip_address, vm.private_ip_address])
    end

    def connection_options
      http_proxy ? {:proxy_url => http_proxy.full_url} : {}
    end

    private

    def client
      @client ||= ::Fog::Compute.new(
        :provider => 'google',
        :google_project => project,
        :google_client_email => email,
        :google_json_key_location => key_path,
        :google_extra_global_projects => ['rhel-sap-cloud'],
        :google_client_options => connection_options
      )
    end

    def construct_network(network_name)
      client.api_url + client.project + "/global/networks/#{network_name}"
    end

    # handle network_interface for external ip
    def construct_network_interfaces(network_interfaces_list, external_ip = nil)
      # assign  ephemeral external IP address using associate_external_ip
      if network_interfaces_list.blank?
        network_interfaces_list = [
          {
            :network => "global/networks/#{::Fog::Compute::Google::GOOGLE_COMPUTE_DEFAULT_NETWORK}",
          },
        ]
      end
      access_config = {
        :name => ::Fog::Compute::Google::Server::EXTERNAL_NAT_NAME,
        :type => ::Fog::Compute::Google::Server::EXTERNAL_NAT_TYPE,
      }
      # Note - no support for external_ip from foreman
      # access_config[:nat_ip] = external_ip if external_ip
      network_interfaces_list[0][:access_configs] = [access_config]
      network_interfaces_list
    end

    def ensure_attributes_and_values
      check_google_key_format_and_options
      validate_zone
    end

    def read_key_file
      return nil unless File.exist?(key_path)
      JSON.parse(File.read(key_path).chomp)
    end

    def check_google_key_format_and_options
      return if key_path.blank?

      key_data = read_key_file
      return errors.add(:key_path, _('Unable to access key')) if key_data.blank?

      unless key_data.is_a?(Hash) && key_data.key?('client_email') && key_data.key?('private_key')
        errors.add(:key_path, _("Invalid Google JSON key. Please verify client email & private key options are present"))
      end
    rescue JSON::ParserError
      errors.add(:key_path, _('Certificate key is not a valid JSON'))
    rescue => e
      Foreman::Logging.exception("Failed to access gce key path", e)
      errors.add(:key_path, e.message.to_s)
    end

    def validate_zone
      errors.add(:zone, 'is not valid') if zone && !zones.include?(zone.to_s.downcase)
    rescue => e
      Foreman::Logging.exception("Failed to connect", e)
      errors[:base] << e.message
    end

    def vm_instance_defaults
      super.merge(
        :zone => zone,
        :name => "foreman-#{Time.now.to_i}",
        :disks => [new_volume]
      )
    end
  end
end
