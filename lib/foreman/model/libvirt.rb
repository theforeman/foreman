module Foreman::Model
  class Libvirt < ComputeResource

    validates_format_of :url, :with => URI.regexp

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

    def test_connection
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

    def networks
      client.interfaces rescue []
    end

    def new_vm attr={ }
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
      raise "Spice display is not supported at the moment" if vm.display[:type] =~ /spice/i
      password = random_password
      vm.update_display(:password => password, :listen => '0')
      VNCProxy.start :host => hypervisor.hostname, :host_port => vm.display[:port], :password => password
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
      Thread.current[url] ||= ::Fog::Compute.new(:provider => "Libvirt", :libvirt_uri => url)
    end

    def disconnect
      client.terminate if Thread.current[url]
      Thread.current[url] = nil
    end

    def vm_instance_defaults
      {
        :memory     => 768*1024*1024,
        :boot_order => %w[network hd],
        :nics       => [new_nic],
        :volumes    => [new_volume],
        :display    => { :type => 'vnc', :listen => '0', :password => random_password, :port => '-1' }
      }
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
