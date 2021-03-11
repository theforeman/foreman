module Foreman::Model
  class Libvirt < ComputeResource
    include ComputeResourceConsoleCommon

    ALLOWED_DISPLAY_TYPES = %w(vnc spice)

    # 'custom' is not implemented. This needs extra UI.
    CPU_MODES = %w(default host-model host-passthrough)

    validates :url, :format => { :with => URI::DEFAULT_PARSER.make_regexp }, :presence => true
    validates :display_type, :inclusion => { :in => ALLOWED_DISPLAY_TYPES }

    def self.available?
      Fog::Compute.providers.include?(:libvirt)
    end

    # Some getters/setters for the attrs Hash
    def display_type
      attrs[:display].presence || 'vnc'
    end

    def display_type=(display)
      attrs[:display] = display.downcase
    end

    def provided_attributes
      super.merge({:mac => :mac})
    end

    def interfaces_attrs_name
      :nics
    end

    def capabilities
      [:build, :image, :new_volume]
    end

    def editable_network_interfaces?
      interfaces.any? || networks.any?
    end

    def find_vm_by_uuid(uuid)
      super
    rescue ::Libvirt::RetrieveError => e
      Foreman::Logging.exception("Failed retrieving libvirt vm by uuid #{uuid}", e)
      raise ActiveRecord::RecordNotFound
    end

    # we default to destroy the VM's storage as well.
    def destroy_vm(uuid, args = { })
      find_vm_by_uuid(uuid).destroy({ :destroy_volumes => true }.merge(args))
    rescue ActiveRecord::RecordNotFound
      true
    end

    def self.model_name
      ComputeResource.model_name
    end

    def max_cpu_count
      hypervisor.cpus
    end

    # returns available memory for VM in bytes
    def max_memory
      # libvirt reports in KB
      hypervisor.memory.kilobyte
    rescue => e
      logger.debug "unable to figure out free memory, guessing instead due to:#{e}"
      16.gigabytes
    end

    def test_connection(options = {})
      super
      errors[:url].empty? && hypervisor
    rescue => e
      disconnect rescue nil
      errors[:base] << e.message
    end

    def new_nic(attr = {})
      client.nics.new attr
    end

    def new_interface(attr = {})
      # fog compatibility
      new_nic(attr)
    end

    def new_volume(attr = {})
      return unless new_volume_errors.empty?
      client.volumes.new(attr.merge(:allocation => '0G'))
    end

    def new_volume_errors
      errors = []
      errors.push _('no storage pool available on hypervisor') if storage_pools.empty?
      errors
    end

    def storage_pools
      client.pools rescue []
    end

    def bridges
      # before ruby-libvirt fixes https://bugzilla.redhat.com/show_bug.cgi?id=1317909 we have to use raw XML to get type
      bridges = client.client.list_all_interfaces.select do |libvirt_interface|
        type_match = libvirt_interface.xml_desc.match /<interface.*?type=['"]([a-z]+)['"]/
        type_match[1] == 'bridge'
      end
      bridge_names = bridges.map(&:name)
      interfaces.select { |fog_interface| fog_interface.active? && bridge_names.include?(fog_interface.name) }
    rescue => e
      Foreman::Logging.exception('No bridge interface could be found in libvirt', e)
      []
    end

    def interfaces
      client.interfaces rescue []
    end

    def networks
      client.networks rescue []
    end

    def template(id)
      template = client.volumes.get(id)
      raise Foreman::Exception.new(N_("Unable to find template %s"), id) unless template.persisted?
      template
    end

    def new_vm(attr = { })
      test_connection
      libvirt_connection_error unless errors.empty?
      opts = vm_instance_defaults.merge(attr.to_h).deep_symbolize_keys

      # convert rails nested_attributes into a plain hash
      [:nics, :volumes].each do |collection|
        nested_attrs = opts.delete("#{collection}_attributes".to_sym)
        opts[collection] = nested_attributes_for(collection, nested_attrs) if nested_attrs
      end

      opts.reject! { |k, v| v.nil? }

      opts[:boot_order] = %w[hd]
      opts[:boot_order].unshift 'network' unless attr[:image_id]

      vm = client.servers.new opts
      vm.memory = opts[:memory] if opts[:memory]
      vm
    end

    def create_vm(args = { })
      vm = new_vm(args)
      create_volumes :prefix => vm.name, :volumes => vm.volumes, :backing_id => args[:image_id]
      vm.save
    rescue Fog::Errors::Error => e
      Foreman::Logging.exception("Unhandled Libvirt error", e)
      begin
        destroy_vm vm.id if vm&.id
      rescue Fog::Errors::Error => destroy_e
        Foreman::Logging.exception("Libvirt destroy failed for #{vm.id}", destroy_e)
      end
      raise e
    end

    def console(uuid)
      vm = find_vm_by_uuid(uuid)
      raise Foreman::Exception.new(N_("VM is not running!")) unless vm.ready?
      password = random_password
      # Listen address cannot be updated while the guest is running
      # When we update the display password, we pass the existing listen address
      vm.update_display(:password => password, :listen => vm.display[:listen], :type => vm.display[:type])
      WsProxy.start(:host => hypervisor.hostname, :host_port => vm.display[:port], :password => password).merge(:type => vm.display[:type], :name => vm.name)
    rescue ::Libvirt::Error => e
      if e.message =~ /cannot change listen address/
        logger.warn e
        Foreman::Exception.new(N_("Unable to change VM display listen address, make sure the display is not attached to localhost only"))
      else
        raise e
      end
    end

    def hypervisor
      client.nodes.first
    end

    def associated_host(vm)
      associate_by("mac", vm.interfaces.map(&:mac))
    end

    def vm_compute_attributes(vm)
      vm_attrs = super
      if vm_attrs[:memory_size].nil?
        vm_attrs[:memory] = nil
        logger.debug("Compute attributes for VM didn't contain :memory_size")
      else
        vm_attrs[:memory] = vm_attrs[:memory_size] * 1024 # value is returned in megabytes, we need bytes
      end
      vm_attrs
    end

    def normalize_vm_attrs(vm_attrs)
      normalized = slice_vm_attributes(vm_attrs, ['cpus', 'memory', 'image_id'])

      normalized['image_name'] = images.find_by(:uuid => vm_attrs['image_id']).try(:name)

      volume_attrs = vm_attrs['volumes_attributes'] || {}
      normalized['volumes_attributes'] = volume_attrs.each_with_object({}) do |(key, vol), volumes|
        volumes[key] = {
          'capacity' => memory_gb_to_bytes(vol['capacity']).to_s,
          'allocation' => memory_gb_to_bytes(vol['allocation']).to_s,
          'format_type' => vol['format_type'],
          'pool' => vol['pool_name'],
        }
      end

      interface_attrs = vm_attrs['nics_attributes'] || {}
      normalized['interfaces_attributes'] = interface_attrs.each_with_object({}) do |(key, nic), interfaces|
        interfaces[key] = {
          'type' => nic['type'],
          'model' => nic['model'],
        }
        if nic['type'] == 'network'
          interfaces[key]['network'] = nic['network']
        else
          interfaces[key]['bridge'] = nic['bridge']
        end
      end

      normalized
    end

    protected

    def libvirt_connection_error
      msg = N_('Unable to connect to libvirt due to: %s. Please make sure your libvirt compute resource is reachable and that you have appropriate access permissions.')
      raise Foreman::Exception.new(msg, errors.full_messages.join(', '))
    end

    def client
      # WARNING potential connection leak
      tries ||= 3
      Thread.current[url] ||= ::Fog::Compute.new(:provider => "Libvirt", :libvirt_uri => url)
    rescue ::Libvirt::RetrieveError
      Thread.current[url] = nil
      retry unless (tries -= 1).zero?
    end

    def disconnect
      client.terminate if Thread.current[url]
      Thread.current[url] = nil
    end

    def vm_instance_defaults
      super.merge(
        :memory     => 2048.megabytes,
        :nics       => [new_nic],
        :volumes    => [new_volume].compact,
        :display    => { :type     => display_type,
                         :listen   => Setting[:libvirt_default_console_address],
                         :password => random_password,
                         :port     => '-1' }
      )
    end

    def create_volumes(args)
      args[:volumes].each { |vol| validate_volume_capacity(vol) }

      # if using image creation, the first volume needs a backing disk set
      if args[:backing_id].present?
        raise ::Foreman::Exception.new(N_('At least one volume must be specified for image-based provisioning.')) unless args[:volumes].size >= 1
        args[:volumes].first.backing_volume = template(args[:backing_id])
      end

      begin
        vols = []
        (volumes = args[:volumes]).each do |vol|
          vol.name = "#{args[:prefix]}-disk#{volumes.index(vol) + 1}"
          vol.capacity = "#{vol.capacity}G" unless vol.capacity.to_s.end_with?('G')
          if vol.allocation.match(/^\d+/) && !vol.allocation.to_s.end_with?('G')
            vol.allocation = "#{vol.allocation}G"
          end
          vol.save
          vols << vol
        end
        vols
      rescue => e
        logger.error "Failure detected #{e}: removing already created volumes" if vols.any?
        vols.each { |vol| vol.destroy }
        raise e
      end
    end

    def validate_volume_capacity(vol)
      if vol.capacity.to_s.empty? || /\A\d+G?\Z/.match(vol.capacity.to_s).nil?
        raise Foreman::Exception.new(N_("Please specify volume size. You may optionally use suffix 'G' to specify volume size in gigabytes."))
      end
    end
  end
end
