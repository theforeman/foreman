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

   # vSphere guest OS type descriptions
   # list fetched from RbVmomi::VIM::VirtualMachineGuestOsIdentifier.values
   def guest_types_descriptions
      {
        "dosGuest" => "Microsoft MS-DOS",
        "win31Guest" => "Microsoft Windows 3.1",
        "win95Guest" => "Microsoft Windows 95",
        "win98Guest" => "Microsoft Windows 98",
        "winMeGuest" => "Microsoft Windows Millenium Edition",
        "winNTGuest" => "Microsoft Windows NT",
        "win2000ProGuest" => "Microsoft Windows 2000 Professional",
        "win2000ServGuest" => "Microsoft Windows 2000 Server",
        "win2000AdvServGuest" => "Microsoft Windows 2000 Advanced Server",
        "winXPHomeGuest" => "Microsoft Windows XP Home Edition",
        "winXPProGuest" => "Microsoft Windows XP Professional (32-bit)",
        "winXPPro64Guest" => "Microsoft Windows XP Professional (64-bit)",
        "winNetWebGuest" => "Microsoft Windows Server 2003 Web Edition (32-bit)",
        "winNetStandardGuest" => "Microsoft Windows Server 2003 Standard Edition (32-bit)",
        "winNetEnterpriseGuest" => "Microsoft Windows Server 2003 Enterprise Edition (32-bit)",
        "winNetDatacenterGuest" => "Microsoft Windows Server 2003 Datacenter Edition (32-bit)",
        "winNetBusinessGuest" => "Microsoft Windows Small Business Server 2003",
        "winNetStandard64Guest" => "Microsoft Windows Server 2003 Standard Edition (64-bit)",
        "winNetEnterprise64Guest" => "Microsoft Windows Server 2003 Enterprise Edition (64-bit)",
        "winLonghornGuest" => "Microsoft Windows Longhorn (32-bit)",
        "winLonghorn64Guest" => "Microsoft Windows Longhorn (64-bit)",
        "winNetDatacenter64Guest" => "Microsoft Windows Server 2003 Datacenter Edition (64-bit)",
        "winVistaGuest" => "Microsoft Windows Vista (32-bit)",
        "winVista64Guest" => "Microsoft Windows Vista (64-bit)",
        "windows7Guest" => "Microsoft Windows 7 (32-bit)",
        "windows7_64Guest" => "Microsoft Windows 7 (64-bit)",
        "windows7Server64Guest" => "Microsoft Windows Server 2008 R2 (64-bit)",
        "windows8Guest" => "Microsoft Windows 8 (32-bit)",
        "windows8_64Guest" => "Microsoft Windows 8 (64-bit)",
        "windows8Server64Guest" => "Microsoft Windows Server 2012 (64-bit)",
        "freebsd64Guest" => "FreeBSD (64-bit)",
        "freebsdGuest" => "FreeBSD (32-bit)",
        "redhatGuest" => "Red Hat Linux 2.1",
        "rhel2Guest" => "Red Hat Enterprise Linux 2.1",
        "rhel3Guest" => "Red Hat Enterprise Linux 3 (32-bit)",
        "rhel3_64Guest" => "Red Hat Enterprise Linux 3 (64-bit)",
        "rhel4Guest" => "Red Hat Enterprise Linux 4 (32-bit)",
        "rhel4_64Guest" => "Red Hat Enterprise Linux 4 (64-bit)",
        "rhel5Guest" => "Red Hat Enterprise Linux 5 (32-bit)",
        "rhel5_64Guest" => "Red Hat Enterprise Linux 5 (64-bit)",
        "rhel6Guest" => "Red Hat Enterprise Linux 6 (32-bit)",
        "rhel6_64Guest" => "Red Hat Enterprise Linux 6 (64-bit)",
        "centosGuest" => "CentOS 4/5/6 (32-bit)",
        "centos64Guest" => "CentOS 4/5/6 (64-bit)",
        "oracleLinux64Guest" => "Oracle Linux 4/5/6 (64-bit)",
        "oracleLinuxGuest" => "Oracle Linux 4/5/6 (32-bit)",
        "suseGuest" => "Suse Linux (32-bit)",
        "suse64Guest" => "Suse Linux (64-bit)",
        "slesGuest" => "Novell SUSE Linux Enterprise 8/9 (32-bit)",
        "sles64Guest" => "Novell SUSE Linux Enterprise 8/9 (64-bit)",
        "sles10Guest" => "Novell SUSE Linux Enterprise 10 (32-bit)",
        "sles10_64Guest" => "Novell SUSE Linux Enterprise 10 (64-bit)",
        "sles11Guest" => "Novell SUSE Linux Enterprise 11 (32-bit)",
        "sles11_64Guest" => "Novell SUSE Linux Enterprise 11 (64-bit)",
        "nld9Guest" => "Novell Linux Desktop 9",
        "oesGuest" => "Novell Open Enterprise Server",
        "sjdsGuest" => "Sun Java Desktop System",
        "mandrivaGuest" => "Mandriva Linux (32-bit)",
        "mandriva64Guest" => "Mandriva Linux (64-bit)",
        "turboLinuxGuest" => "Turbolinux (32-bit)",
        "turboLinux64Guest" => "Turbolinux (64-bit)",
        "ubuntu64Guest" => "Ubuntu Linux (64-bit)",
        "ubuntuGuest" => "Ubuntu Linux (32-bit)",
        "debian4Guest" => "Debian GNU/Linux 4 (32-bit)",
        "debian4_64Guest" => "Debian GNU/Linux 5 (64-bit)",
        "debian5Guest" => "Debian GNU/Linux 5 (32-bit)",
        "debian5_64Guest" => "Debian GNU/Linux 5 (64-bit)",
        "debian6Guest" => "Debian GNU/Linux 6 (32-bit)",
        "debian6_64Guest" => "Debian GNU/Linux 6 (64-bit)",
        "asianux3Guest" => "Asianux Server 3 (32-bit)",
        "asianux3_64Guest" => "Asianux Server 3 (64-bit)",
        "asianux4Guest" => "Asianux Server 4 (32-bit)",
        "asianux4_64Guest" => "Asianux Server 4 (64-bit)",
        "opensuseGuest" => "OpenSUSE Linux (32-bit)",
        "opensuse64Guest" => "OpenSUSE Linux (64-bit)",
        "other24xLinuxGuest" => "Other 2.4.x Linux (32-bit)",
        "other26xLinuxGuest" => "Other 2.6.x Linux (32-bit)",
        "otherLinuxGuest" => "Other Linux (32-bit)",
        "other24xLinux64Guest" => "Other 2.4.x Linux (64-bit)",
        "other26xLinux64Guest" => "Other 2.6.x Linux (64-bit)",
        "otherLinux64Guest" => "Other Linux (64-bit)",
        "solaris6Guest" => "Sun Microsystems Solaris 6",
        "solaris7Guest" => "Sun Microsystems Solaris 7",
        "solaris8Guest" => "Sun Microsystems Solaris 8",
        "solaris9Guest" => "Sun Microsystems Solaris 9",
        "solaris10Guest" => "Oracle Solaris 10 (32-bit)",
        "solaris10_64Guest" => "Oracle Solaris 10 (64-bit)",
        "solaris11_64Guest" => "Oracle Solaris 11 (64-bit)",
        "os2Guest" => "IBM OS/2",
        "eComStationGuest" => "Serenity Systems eComStation 1.x",
        "eComStation2Guest" => "Serenity Systems eComStation 2.0",
        "netware4Guest" => "Novell NetWare 4",
        "netware5Guest" => "Novell NetWare 5.1",
        "netware6Guest" => "Novell NetWare 6.x",
        "openServer5Guest" => "SCO OpenServer 5",
        "openServer6Guest" => "SCO OpenServer 6",
        "unixWare7Guest" => "SCO UnixWare 7",
        "darwinGuest" => "Apple Mac OS X 10.5 (32-bit)",
        "darwin64Guest" => "Apple Mac OS X 10.5 (64-bit)",
        "darwin10Guest" => "Apple Mac OS X 10.6 (32-bit)",
        "darwin10_64Guest" => "Apple Mac OS X 10.6 (64-bit)",
        "darwin11Guest" => "Apple Mac OS X 10.7 (32-bit)",
        "darwin11_64Guest" => "Apple Mac OS X 10.7 (64-bit)",
        "vmkernelGuest" => "VMWare ESX 4.x",
        "vmkernel5Guest" => "VMWare ESXi 5.x",
        "otherGuest" => "Other (32-bit)",
        "otherGuest64" => "Other (64-bit)"
      }
    end

    def guest_types
      types = { }
      RbVmomi::VIM::VirtualMachineGuestOsIdentifier.values.compact.each do |v|
        types[v] = guest_types_descriptions.has_key?(v) ? guest_types_descriptions[v] : v
      end
      types
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
      path_replace = %r{/Datacenters/#{datacenter}/vm(/|)}

      interfaces = client.list_vm_interfaces(args["image_id"])
      interface = interfaces.detect{|i| i[:name] == "Network adapter 1" }
      network_adapter_device_key = interface[:key]

      opts = {
        "datacenter" => datacenter,
        "template_path" => args["image_id"],
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
      client.servers.get(client.vm_clone(opts)['new_vm']['id'])
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

