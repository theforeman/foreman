module Foreman::Model
  class Libvirt < ComputeResource

    validates_format_of :url, :with => URI.regexp

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

    def capabilities
      [:build]
    end

    def find_vm_by_uuid uuid
      client.servers.get(uuid)
    rescue ::Libvirt::RetrieveError => e
      raise(ActiveRecord::RecordNotFound)
    end

    # we default to destroy the VM's storage as well.
    def destroy_vm uuid, args = { }
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
      hypervisor.memory * 1024
    rescue => e
      logger.debug "unable to figure out free memory, guessing instead due to:#{e}"
      16*1024*1024*1024
    end

    def test_connection options = {}
      super
      errors[:url].empty? and hypervisor
    rescue => e
      disconnect rescue nil
      errors[:base] << e.message
    end

    def new_nic attr={ }
      client.nics.new attr
    end

    def new_volume attr={ }
      client.volumes.new attr
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

    def new_vm attr={ }
      test_connection
      return unless errors.empty?
      opts = vm_instance_defaults.merge(attr.to_hash).symbolize_keys

      # convert rails nested_attributes into a plain hash
      [:nics, :volumes].each do |collection|
        nested_attrs = opts.delete("#{collection}_attributes".to_sym)
        opts[collection] = nested_attributes_for(collection, nested_attrs) if nested_attrs
      end

      opts.reject! { |k, v| v.nil? }

      vm = client.servers.new opts
      vm.memory = opts[:memory] if opts[:memory]
      vm
    end

    def create_vm args = { }
      vm = new_vm(args)
      create_volumes :prefix => vm.name, :volumes => vm.volumes

      vm.save
    rescue Fog::Errors::Error => e
      errors.add(:base, e.to_s)
      false
    end

    def console uuid
      vm = find_vm_by_uuid(uuid)
      raise "VM is not running!" unless vm.ready?
      password = random_password
      # Listen address cannot be updated while the guest is running
      # When we update the display password, we pass the existing listen address
      vm.update_display(:password => password, :listen => vm.display[:listen], :type => vm.display[:type])
      WsProxy.start(:host => hypervisor.hostname, :host_port => vm.display[:port], :password => password).merge(:type =>  vm.display[:type].downcase, :name=> vm.name)
    rescue ::Libvirt::Error => e
      if e.message =~ /cannot change listen address/
        logger.warn e
        raise "Unable to change VM display listen address, make sure the display is not attached to localhost only"
      else
        raise e
      end
    end

    def hypervisor
      client.nodes.first
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
        :memory     => 768*1024*1024,
        :boot_order => %w[network hd],
        :nics       => [new_nic],
        :volumes    => [new_volume],
        :display    => {
                         :type => display_type.downcase,
                         :listen => Setting[:libvirt_default_console_address],
                         :password => random_password,
                         :port => '-1'
                       }
      )
    end

    def create_volumes args
      vols = []
      (volumes = args[:volumes]).each do |vol|
        vol.name       = "#{args[:prefix]}-disk#{volumes.index(vol)+1}"
        vol.allocation = "0G"
        vol.save
        vols << vol
      end
      vols
    rescue => e
      logger.debug "Failure detected #{e}: removing already created volumes" if vols.any?
      vols.each { |vol| vol.destroy }
      raise e
    end

  end
end
