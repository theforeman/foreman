module Foreman::Model
  class Libvirt < ComputeResource
    include ComputeResourceConsoleCommon

    validates :url, :format => { :with => URI.regexp }

    # Some getters/setters for the attrs Hash
    def display_type
      self.attrs[:display].present? ? self.attrs[:display] : 'vnc'
    end

    def display_type=(display)
      self.attrs[:display] = display
    end

    def provided_attributes
      super.merge({:mac => :mac})
    end

    def interfaces_attrs_name
      "nics"
    end

    def capabilities
      [:build, :image]
    end

    def find_vm_by_uuid(uuid)
      client.servers.get(uuid)
    rescue ::Libvirt::RetrieveError => e
      logger.error e.message
      logger.error e.backtrace.join("\n")
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

    # libvirt reports in KB
    def max_memory
      hypervisor.memory * Foreman::SIZE[:kilo]
    rescue => e
      logger.debug "unable to figure out free memory, guessing instead due to:#{e}"
      16*Foreman::SIZE[:giga]
    end

    def test_connection(options = {})
      super
      errors[:url].empty? and hypervisor
    rescue => e
      disconnect rescue nil
      errors[:base] << e.message
    end

    def new_nic(attr = { })
      client.nics.new attr
    end

    def new_interface(attr = {})
      # fog compatibility
      new_nic(attr)
    end

    def new_volume(attr = { })
      client.volumes.new(attrs.merge(:allocation => '0G'))
    end

    def storage_pools
      client.pools rescue []
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
      return unless errors.empty?
      opts = vm_instance_defaults.merge(attr.to_hash).deep_symbolize_keys

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
      logger.error "Unhandled LibVirt error: #{e.class}:#{e.message}\n " + e.backtrace.join("\n ")
      destroy_vm vm.id if vm
      raise e
    end

    def console(uuid)
      vm = find_vm_by_uuid(uuid)
      raise Foreman::Exception.new(N_("VM is not running!")) unless vm.ready?
      password = random_password
      # Listen address cannot be updated while the guest is running
      # When we update the display password, we pass the existing listen address
      vm.update_display(:password => password, :listen => vm.display[:listen], :type => vm.display[:type])
      WsProxy.start(:host => hypervisor.hostname, :host_port => vm.display[:port], :password => password).merge(:type =>  vm.display[:type].downcase, :name=> vm.name)
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
      associate_by("mac", vm.mac)
    end

    protected

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
        :memory     => 768*Foreman::SIZE[:mega],
        :nics       => [new_nic],
        :volumes    => [new_volume],
        :display    => { :type     => display_type.downcase,
                         :listen   => Setting[:libvirt_default_console_address],
                         :password => random_password,
                         :port     => '-1' }
      )
    end

    def create_volumes(args)
      args[:volumes].each {|vol| validate_volume_capacity(vol)}

      # if using image creation, the first volume needs a backing disk set
      if args[:backing_id].present?
        raise ::Foreman::Exception.new(N_('At least one volume must be specified for image-based provisioning.')) unless args[:volumes].size >= 1
        args[:volumes].first.backing_volume = template(args[:backing_id])
      end

      begin
        vols = []
        (volumes = args[:volumes]).each do |vol|
          vol.name       = "#{args[:prefix]}-disk#{volumes.index(vol)+1}"
          vol.capacity = "#{vol.capacity}G" unless vol.capacity.to_s.end_with?('G')
          vol.allocation = "#{vol.allocation}G" unless vol.allocation.to_s.end_with?('G')
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
      if vol.capacity.to_s.empty? or /\A\d+G?\Z/.match(vol.capacity.to_s).nil?
        raise Foreman::Exception.new(N_("Please specify volume size. You may optionally use suffix 'G' to specify volume size in gigabytes."))
      end
    end
  end
end
