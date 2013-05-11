require 'fog_extensions/vsphere/mini_servers'

module Foreman::Model
  class Vmware < ComputeResource

    NETWORK_INTERFACE_TYPES = %w(VirtualE1000)
    validates_presence_of :user, :password, :server, :datacenter
    before_create :update_public_key

    def self.model_name
      ComputeResource.model_name
    end

    def capabilities
      [:build]
    end

    def vms(opts = {})
      if opts[:eager_loading] == true
        super()
      else
        #VMWare server loading is very slow
        #not using FOG models directly to save the time
        #and minimize the amount of time required (as we don't require all attributes by default when listing)
        FogExtensions::Vsphere::MiniServers.new(client, datacenter)
      end
    end

    def provided_attributes
      super.merge({ :mac => :mac })
    end

    def max_cpu_count (cluster = nil)
      return 8 unless cluster
      cluster.num_cpu_cores
    end

    def max_memory
      16*1024*1024*1024
    end

    def datacenters
      client.datacenters.all
    end

    def clusters
      dc.clusters
    end

    def folders
      dc.vm_folders.sort_by{|f| f.path}
    end

    def networks
      dc.networks.all(:accessible => true)
    end

    def datastores
      dc.datastores.all(:accessible => true)
    end

    def hardware_profiles
      servertypes
    end
    
    def hardware_profile(id)
      servertypes.get(id)
    end

    def servertypes
      @servertypes ||= dc.servertypes.all()
    end

    def test_connection
      super
      errors[:server] and errors[:user].empty? and errors[:password] and update_public_key and datacenters
    rescue => e
      errors[:base] << e.message
    end

    def new_vm attr={ }
      opts = vm_instance_defaults.merge(attr.to_hash).symbolize_keys

      # convert rails nested_attributes into a plain hash
      [:interfaces, :volumes].each do |collection|
        nested_attrs = opts.delete("#{collection}_attributes".to_sym)
        opts[collection] = nested_attributes_for(collection, nested_attrs) if nested_attrs
      end

      opts.reject! { |k, v| v.nil? }

      client.servers.new opts
    end

    def create_vm args = { }
      vm = new_vm(args)

      vm.save
    rescue Fog::Errors::Error => e
      logger.debug e.backtrace
      errors.add(:base, e.to_s)
      false
    end

    def server
      url
    end

    def server= value
      self.url = value
    end

    def datacenter
      uuid
    end

    def datacenter= value
      self.uuid = value
    end

    def console uuid
      vm = find_vm_by_uuid(uuid)
      raise "VM is not running!" unless vm.ready?
      #TOOD port, password
      #NOTE this requires the following port to be open on your ESXi FW
      values = { :port => unused_vnc_port(vm.hypervisor), :password => random_password, :enabled => true }
      vm.config_vnc(values)
      WsProxy.start(:host => vm.hypervisor, :host_port => values[:port], :password => values[:password]).merge(:type => 'vnc')
    end

    def new_interface attr = { }
      client.interfaces.new attr
    end

    def new_volume attr = { }
      client.volumes.new attr.merge(:size_gb => 10)
    end

    private

    def dc
      client.datacenters.get(datacenter)
    end

    def update_public_key
      return unless pubkey_hash.blank?
      client
    rescue => e
      if e.message =~ /The remote system presented a public key with hash (\w+) but we're expecting a hash of/
        self.pubkey_hash = $1
      else
        raise e
      end
    end

    def pubkey_hash
      attrs[:pubkey_hash]
    end

    def pubkey_hash= key
      attrs[:pubkey_hash] = key
    end

    def client
      @client ||= ::Fog::Compute.new(
        :provider                     => "vsphere",
        :vsphere_username             => user,
        :vsphere_password             => password,
        :vsphere_server               => server,
        :vsphere_expected_pubkey_hash => pubkey_hash
      )
    end

    def unused_vnc_port ip
      10.times do
        port   = 5901 + rand(64)
        unused = (TCPSocket.connect(ip, port).close rescue true)
        return port if unused
      end
      raise "no unused port found"
    end

    def vm_instance_defaults
      {
        :memory_mb  => 768,
        :interfaces => [new_interface],
        :volumes    => [new_volume],
        :datacenter => datacenter,
        :guest_id   => "otherGuest64"
      }.merge(super)
    end

  end
end
