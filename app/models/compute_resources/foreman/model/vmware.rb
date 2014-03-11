require 'fog_extensions/vsphere/mini_servers'
require 'foreman/exception'

module Foreman::Model
  class Vmware < ComputeResource

    validates :user, :password, :server, :datacenter, :presence => true
    before_create :update_public_key

    def self.model_name
      ComputeResource.model_name
    end

    def capabilities
      [:build, :image]
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

    def networks(opts ={})
      dc.networks.all(:accessible => true)
    end

    def available_clusters
      clusters
    end

    def available_networks(cluster_id=nil)
      networks
    end

    def available_storage_domains
      datastores
    end

    def nictypes
      {
        "VirtualE1000" => "E1000",
        "VirtualVmxnet3" => "VMXNET 3"
      }
    end

    def scsi_controller_types
      {
        "VirtualLsiLogicController" => "LSI Logic Parallel",
        "VirtualLsiLogicSASController" => "LSI Logic SAS",
        "VirtualBusLogicController" => "Bus Logic Parallel",
        "ParaVirtualSCSIController" => "VMware Paravirtual"
      }
    end

    def scsi_controller_default_type
      "VirtualLsiLogicController"
    end

    def datastores
      dc.datastores.all(:accessible => true)
    end

    def test_connection options = {}
      super
      if errors[:server].empty? and errors[:user].empty? and errors[:password].empty?
        update_public_key options
        datacenters
      end
    rescue => e
      errors[:base] << e.message
    end

    def parse_args args
      dc_networks = networks
      args["interfaces_attributes"].each do |key, interface|
        # Convert network id into name
        net = dc_networks.find { |n| n.id == interface["network"] }
        raise "Unknown Network ID: #{interface["network"]}" if net.nil?
        interface["network"] = net.name
      end

      # convert rails nested_attributes into a plain hash
      [:interfaces, :volumes].each do |collection|
        nested_attrs = args.delete("#{collection}_attributes".to_sym)
        args[collection] = nested_attributes_for(collection, nested_attrs) if nested_attrs
      end

      args.reject! { |k, v| v.nil? }
      args
    end

    def create_vm controller_args = { }
      args = parse_args controller_args.dup

      test_connection
      return unless errors.empty?

      if args["image_id"]
        clone_vm(args)
      else
        vm = new_vm(args)
        vm.save
      end
    rescue Fog::Errors::Error => e
      logger.debug e.backtrace
      errors.add(:base, e.to_s)
      false
    end

    def new_vm args
      opts = vm_instance_defaults.merge(args.to_hash).symbolize_keys
      client.servers.new opts
    end

    # === Power on
    #
    # Foreman will try and start this vm after clone in a seperate request.
    #
    # === Clusters
    #
    # Fog adaptor is incompatable with foreman because foreman does not have
    # concept of a resource pool.
    #
    #   "resource_pool" => [args["cluster"], "Resources"]
    #
    # Fog calls +cluster.resourcePool.find("Resources")+ that actually calls
    # +searchIndex.FindChild("Resources")+ in RbVmomi that then returns nil
    # because it has no children.
    def clone_vm args
      vm = client.servers.get(args["image_id"], datacenter)
      path_replace = /\/Datacenters\/#{datacenter}\/vm(\/|)/

      interfaces = client.list_vm_interfaces(args["image_id"])
      interface = interfaces.detect{|i| i[:name] == "Network adapter 1" }
      network_adapter_device_key = interface[:key]

      opts = {
        "dest_folder" => args["path"].gsub(path_replace, ''),
        "power_on" => false,
        "start" => args["start"],
        "name" => args["name"],
        "numCPUs" => args["cpus"],
        "memoryMB" => args["memory_mb"],
        "datastore" => args["volumes"].first["datastore"],
        "network_label" => args["interfaces"].first["network"],
        "network_adapter_device_key" => network_adapter_device_key
      }

      vm.relative_path = vm.folder.path.gsub(path_replace, '')
      vm.clone(opts)
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

    def pubkey_hash
      attrs[:pubkey_hash]
    end

    def pubkey_hash= key
      attrs[:pubkey_hash] = key
    end

    def associated_host(vm)
      Host.authorized(:view_hosts, Host).where(:mac => vm.mac).first
    end

    def provider_friendly_name
      "VMWare"
    end

    private

    def dc
      client.datacenters.get(datacenter)
    end

    def update_public_key options ={}
      return unless pubkey_hash.blank? || options[:force]
      client
    rescue Foreman::FingerprintException => e
      self.pubkey_hash = e.fingerprint
    end

    def client
      @client ||= ::Fog::Compute.new(
        :provider                     => "vsphere",
        :vsphere_username             => user,
        :vsphere_password             => password,
        :vsphere_server               => server,
        :vsphere_expected_pubkey_hash => pubkey_hash
      )
    rescue => e
      if e.message =~ /The remote system presented a public key with hash (\w+) but we're expecting a hash of/
        raise Foreman::FingerprintException.new(
          N_("The remote system presented a public key with hash %s but we're expecting a different hash. If you are sure the remote system is authentic, go to the compute resource edit page, press the 'Test Connection' or 'Load Datacenters' button and submit"), $1)
      else
        raise e
      end
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
      super.merge(
        :memory_mb  => 768,
        :interfaces => [new_interface],
        :volumes    => [new_volume],
        :scsi_controller => { :type => scsi_controller_default_type },
        :datacenter => datacenter
      )
    end

  end
end

