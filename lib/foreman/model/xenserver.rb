module Foreman::Model
  class Xenserver < ComputeResource
    validates_presence_of :url, :user, :password

    def provided_attributes
      super.merge(
      {:uuid => :reference,
		   :mac => :mac
		   })
    end

    def capabilities
      [:build]
    end

    def find_vm_by_uuid ref
      client.servers.get(ref)
    rescue ::Xenserver::RetrieveError => e
      raise(ActiveRecord::RecordNotFound)
    end

    # we default to destroy the VM's storage as well.
    def destroy_vm ref, args = { }
      find_vm_by_uuid(ref).destroy
    rescue ActiveRecord::RecordNotFound
      true
    end

    def self.model_name
      ComputeResource.model_name
    end

    def max_cpu_count
      ## 16 is a max number of cpus per vm according to XenServer doc
      [hypervisor.host_cpus.size, 16].min
    end

    def max_memory
      xenServerMaxDoc = 128*1024*1024*1024
      [hypervisor.metrics.memory_total.to_i, xenServerMaxDoc].min
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
      client.networks.new attr
    end

    def new_volume attr={ }
      client.storage_repositories.new attr
    end

    def storage_pools
      client.storage_repositories rescue []
    end

    def interfaces
      client.interfaces rescue []
    end

    def networks
      client.networks rescue []
    end

    def templates
	    client.servers.templates rescue []
    end

    def custom_templates
      client.servers.custom_templates rescue []
    end

    def builtin_templates
      client.servers.builtin_templates rescue []
    end

    def new_vm attr={ }

      test_connection
      return unless errors.empty?
      opts = vm_instance_defaults.merge(attr.to_hash).symbolize_keys

      [:networks, :volumes].each do |collection|
        nested_attrs = opts.delete("#{collection}_attributes".to_sym)
        opts[collection] = nested_attributes_for(collection, nested_attrs) if nested_attrs
      end
     opts.reject! { |k, v| v.nil? }
     client.servers.new opts
    end

    def create_vm args = {}
      custom_template_name = args[:custom_template_name]
      builtin_template_name = args[:builtin_template_name]
      raise "only custom or built-in template can be choosen" if builtin_template_name != "" and custom_template_name != ""
      raise "custom or built-in template has to be choosen" if builtin_template_name == "" and custom_template_name == ""
      begin
        if custom_template_name != ""
          return create_vm_from_custom args
        elsif builtin_template_name != ""
          return create_vm_from_builtin args
        end
      rescue => e
        logger.info e
        logger.info e.backtrace.join("\n")
        raise e
      end
    end

    def create_vm_from_custom args
      mem = args[:memory]
      cpus = args[:vcpus_max]
      vm = client.servers.create :name => args[:name],
                                :template_name => args[:custom_template_name],
                                :memory_static_max  => mem,
                                :memory_static_min  => mem,
                                :memory_dynamic_max => mem,
                                :memory_dynamic_min => mem,
                                :vcpus_at_startup => cpus,
                                :vcpus_max => cpus

      logger.info vm
      vm.hard_shutdown
      vm.refresh
      args['xenstore']['vm-data']['ifs']['0']['mac'] = vm.vifs.first.mac
      xenstore_data = xenstore_hash_flatten(args['xenstore'])
      vm.set_attribute('xenstore_data',xenstore_data)
      disks = vm.vbds.select { |vbd| vbd.type == "Disk"}
      i = 1
      disks.each do |vbd|
        vbd.vdi.set_attribute('name-label', "#{args[:name]}-disk#{i}")
        i+=1
      end
      vm
    end

    def create_vm_from_builtin args
    	opts = vm_instance_defaults.merge(args.to_hash).symbolize_keys

    	host = client.hosts.first
    	net = client.networks.find { |n| n.name == "#{args[:VIFs][:print]}" }
    	storage_repository = client.storage_repositories.find { |sr| sr.name == "#{args[:VBDs][:print]}" }
    	logger.info storage_repository
    	vdi = client.vdis.create :name => "#{args[:name]}-disk1",
                       :storage_repository => storage_repository,
                            :description => "#{args[:name]}-disk1",
                            :virtual_size => '8589934592' # ~8GB in bytes
      logger.info vdi
    	mem = args[:memory]
    	cpus = args[:vcpus_max]
    	template = client.servers.builtin_templates.find {|tmp| tmp.name == args[:builtin_template_name]}
    	vm = client.servers.new :name => args[:name],
                        			:affinity => host,
                        			:pv_bootloader => '',
                        			:hvm_boot_params => { :order => 'dn' },
                        			:HVM_boot_policy => 'BIOS order',
                        			:memory_static_max  => mem,
                              :memory_static_min  => mem,
                              :memory_dynamic_max => mem,
                              :memory_dynamic_min => mem,
                              :vcpus_at_startup => cpus,
                              :vcpus_max => cpus

    	vm.save :auto_start => false
    	logger.info client.vbds.create :server => vm, :vdi => vdi
    	net_config = {
    		'MAC_autogenerated' => 'True',
    		'VM' => vm.reference,
    		'network' => net.reference,
    		'MAC' => '',
    		'device' => '0',
    		'MTU' => '0',
    		'other_config' => {},
    		'qos_algorithm_type' => 'ratelimit',
    		'qos_algorithm_params' => {}
    		}
    	logger.info client.create_vif_custom net_config
    	vm.refresh
    	logger.info vm.inspect
    	vm.provision
    	logger.info vm.inspect
    	vm
    end

    def console uuid
      vm = find_vm_by_uuid(uuid)
      raise "VM is not running!" unless vm.ready?
      password = random_password

      console = vm.service.consoles.find {|c| c.__vm == vm.reference && c.protocol == 'rfb'}
      raise "No console fore vm #{vm.name}" if console == nil

      session_ref = (vm.service.instance_variable_get :@connection).instance_variable_get :@credentials
      fullURL = "#{console.location}&session_id=#{session_ref}"
      tunnel = VNCTunnel.new fullURL
      tunnel.start
      logger.info "VNCTunnel started"
      WsProxy.start(:host => tunnel.host, :host_port => tunnel.port, :password => '').merge(:type => 'vnc', :name=> vm.name)

    rescue Error => e
      logger.warn e
      raise e
    end

    def hypervisor
      client.hosts.first
    end

    protected

    def client
      # WARNING potential connection leak
      tries ||= 3
      Thread.current[url] ||= ::Fog::Compute.new({:provider => 'XenServer', :xenserver_url => url, :xenserver_username => user, :xenserver_password => password})
    rescue ::Xenserver::RetrieveError
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
        :networks       => [new_nic],
        :storage_repositories    => [new_volume],
        :display    => { :type => 'vnc', :listen => Setting[:libvirt_default_console_address], :password => random_password, :port => '-1' }
      )
    end

    def create_storage_repositories args
      vols = []
      (storage_repositories = args[:storage_repositories]).each do |vol|
        vol.name       = "#{args[:prefix]}-disk#{storage_repositories.index(vol)+1}"
        vol.allocation = "0G"
        vol.save
        vols << vol
      end
      vols
    rescue => e
      logger.debug "Failure detected #{e}: removing already created storage_repositories" if vols.any?
      vols.each { |vol| vol.destroy }
      raise e
    end

    private
    def xenstore_hash_flatten(nested_hash, key=nil, keychain=nil, out_hash={})
      nested_hash.each do |k, v|
        if v.is_a? Hash then
          out_hash["#{keychain}#{k}"] = ''
          xenstore_hash_flatten(v, k, "#{keychain}#{k}/", out_hash)
        else
          out_hash["#{keychain}#{k}"] = v
        end
      end
      return out_hash
    end
  end
end
