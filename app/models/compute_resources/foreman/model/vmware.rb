require 'fog_extensions/vsphere/mini_servers'
require 'foreman/exception'

module Foreman::Model
  class Vmware < ComputeResource
    include ComputeResourceConsoleCommon
    include ComputeResourceCaching

    validates :user, :password, :server, :datacenter, :presence => true
    before_create :update_public_key

    def self.available?
      Fog::Compute.providers.include?(:vsphere)
    end

    def self.model_name
      ComputeResource.model_name
    end

    def user_data_supported?
      true
    end

    def supports_update?
      true
    end

    def capabilities
      [:build, :image]
    end

    def vms(opts = {})
      if opts[:eager_loading] == true
        super()
      else
        #VMware server loading is very slow
        #not using FOG models directly to save the time
        #and minimize the amount of time required (as we don't require all attributes by default when listing)
        FogExtensions::Vsphere::MiniServers.new(client, datacenter)
      end
    end

    def provided_attributes
      super.merge({ :mac => :mac })
    end

    def max_cpu_count(cluster = nil)
      return 8 unless cluster
      cluster.num_cpu_cores
    end

    def max_memory
      16.gigabytes
    end

    def datacenters
      cache.cache(:datacenters) do
        name_sort(client.datacenters.all)
      end
    end

    def cluster(cluster)
      cache.cache(:"cluster-#{cluster}") do
        dc.clusters.get(cluster)
      end
    end

    def clusters
      dc_clusters = dc.clusters
      if dc_clusters.nil?
        Rails.logger.info "Datacenter #{dc.try(:name)} returned zero clusters"
        return []
      end
      dc_clusters.map(&:full_path).sort
    end

    def datastores(opts = {})
      if opts[:storage_domain]
        cache.cache(:"datastores-#{opts[:storage_domain]}") do
          name_sort(dc.datastores.get(opts[:storage_domain]))
        end
      else
        cache.cache(:datastores) do
          name_sort(dc.datastores.all(:accessible => true))
        end
      end
    end

    def storage_pods(opts = {})
      if opts[:storage_pod]
        cache.cache(:"storage_pods-#{opts[:storage_pod]}") do
          begin
            dc.storage_pods.get(opts[:storage_pod])
          rescue RbVmomi::VIM::InvalidArgument
            {} # Return an empty storage pod hash if vsphere does not support the feature
          end
        end
      else
        cache.cache(:storage_pods) do
          begin
            name_sort(dc.storage_pods.all())
          rescue RbVmomi::VIM::InvalidArgument
            [] # Return an empty set of storage pods if vsphere does not support the feature
          end
        end
      end
    end

    def available_storage_pods(storage_pod = nil)
      storage_pods({:storage_pod => storage_pod})
    end

    def folders
      cache.cache(:folders) do
        dc.vm_folders.sort_by{|f| [f.path, f.name]}
      end
    end

    def networks(opts = {})
      cache.cache(:networks) do
        name_sort(dc.networks.all(:accessible => true))
      end
    end

    def resource_pools(opts = {})
      cluster = cluster(opts[:cluster_id])
      cache.cache(:resource_pools) do
        name_sort(cluster.resource_pools.all(:accessible => true))
      end
    end

    def available_clusters
      cache.cache(:clusters) do
        name_sort(dc.clusters)
      end
    end

    def available_folders
      folders
    end

    def available_networks(cluster_id = nil)
      networks
    end

    def available_storage_domains(storage_domain = nil)
      datastores({:storage_domain => storage_domain})
    end

    def available_resource_pools(opts = {})
      resource_pools({ :cluster_id => opts[:cluster_id] })
    end

    def nictypes
      {
        "VirtualE1000" => "E1000",
        "VirtualVmxnet3" => "VMXNET 3"
      }
    end

    def scsi_controller_types
      {
        "VirtualBusLogicController" => "Bus Logic Parallel",
        "VirtualLsiLogicController" => "LSI Logic Parallel",
        "VirtualLsiLogicSASController" => "LSI Logic SAS",
        "ParaVirtualSCSIController" => "VMware Paravirtual"
      }
    end

    def firmware_types
      {
        "automatic" => N_("Automatic"),
        "bios" => N_("BIOS"),
        "efi" => N_("EFI")
      }
    end

    # vSphere guest OS type descriptions
    # list fetched from RbVmomi::VIM::VirtualMachineGuestOsIdentifier.values and
    # http://pubs.vmware.com/vsphere-60/topic/com.vmware.wssdk.apiref.doc/vim.vm.GuestOsDescriptor.GuestOsIdentifier.html
    # rubocop:disable MethodLength
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
        "windows9Guest" => "Microsoft Windows 10 (32-bit)",
        "windows9_64Guest" => "Microsoft Windows 10 (64-bit)",
        "windows9Server64Guest" => "Microsoft Windows Server Threshhold (64-bit)",
        "windowsHyperVGuest" => "Microsoft Windows Hyper-V",
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
        "rhel7Guest" => "Red Hat Enterprise Linux 7 (32-bit)",
        "rhel7_64Guest" => "Red Hat Enterprise Linux 7 (64-bit)",
        "centosGuest" => "CentOS 4/5/6 (32-bit)",
        "centos64Guest" => "CentOS 4/5/6/7 (64-bit)",
        "coreos64Guest" => "CoreOS Linux (64-bit)",
        "oracleLinux64Guest" => "Oracle Linux 4/5/6/7 (64-bit)",
        "oracleLinuxGuest" => "Oracle Linux 4/5/6 (32-bit)",
        "suseGuest" => "Suse Linux (32-bit)",
        "suse64Guest" => "Suse Linux (64-bit)",
        "slesGuest" => "SUSE Linux Enterprise 8/9 (32-bit)",
        "sles64Guest" => "SUSE Linux Enterprise 8/9 (64-bit)",
        "sles10Guest" => "SUSE Linux Enterprise 10 (32-bit)",
        "sles10_64Guest" => "SUSE Linux Enterprise 10 (64-bit)",
        "sles11Guest" => "SUSE Linux Enterprise 11 (32-bit)",
        "sles11_64Guest" => "SUSE Linux Enterprise 11 (64-bit)",
        "sles12Guest" => "SUSE Linux Enterprise 12 (32-bit)",
        "sles12_64Guest" => "SUSE Linux Enterprise 12 (64-bit)",
        "nld9Guest" => "Novell Linux Desktop 9",
        "oesGuest" => "Novell Open Enterprise Server",
        "sjdsGuest" => "Sun Java Desktop System",
        "mandrakeGuest" => "Mandrake Linux",
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
        "debian7Guest" => "Debian GNU/Linux 7 (32-bit)",
        "debian7_64Guest" => "Debian GNU/Linux 7 (64-bit)",
        "debian8Guest" => "Debian GNU/Linux 8 (32-bit)",
        "debian8_64Guest" => "Debian GNU/Linux 8 (64-bit)",
        "asianux3Guest" => "Asianux Server 3 (32-bit)",
        "asianux3_64Guest" => "Asianux Server 3 (64-bit)",
        "asianux4Guest" => "Asianux Server 4 (32-bit)",
        "asianux4_64Guest" => "Asianux Server 4 (64-bit)",
        "asianux5_64Guest" => "Asianux Server 5 (64-bit)",
        "opensuseGuest" => "SUSE OpenSUSE (32-bit)",
        "opensuse64Guest" => "SUSE OpenSUSE Linux (64-bit)",
        "fedoraGuest" => "Fedora Linux",
        "fedora64Guest" => "Fedora Linux (64-bit)",
        "other24xLinuxGuest" => "Other 2.4.x Linux (32-bit)",
        "other26xLinuxGuest" => "Other 2.6.x Linux (32-bit)",
        "other3xLinuxGuest" => "Other Linux 3.x Guest",
        "otherLinuxGuest" => "Other Linux (32-bit)",
        "genericLinuxGuest" => "Other Linux",
        "other24xLinux64Guest" => "Other 2.4.x Linux (64-bit)",
        "other26xLinux64Guest" => "Other 2.6.x Linux (64-bit)",
        "other3xLinux64Guest" => "Other Linux 3.x Guest (64-bit)",
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
        "darwin12_64Guest" => "Mac OS 10.8 (64-bit)",
        "darwin13_64Guest" => "Mac OS 10.9 (64-bit)",
        "vmkernelGuest" => "VMware ESX 4.x",
        "vmkernel5Guest" => "VMware ESXi 5.x",
        "vmkernel6Guest" => "VMware ESXi 6.x",
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

    def vm_hw_versions
      {
        'Default' => _("Default"),
        'vmx-11' => '11 (ESXi 6.0)',
        'vmx-10' => '10 (ESXi 5.5)',
        'vmx-09' => '9 (ESXi 5.1)',
        'vmx-08' => '8 (ESXi 5.0)',
        'vmx-07' => '7 (ESX/ESXi 4.x)',
        'vmx-04' => '4 (ESX/ESXi 3.5)'
      }
    end

    def test_connection(options = {})
      super
      if errors[:server].empty? && errors[:user].empty? && errors[:password].empty?
        update_public_key options
        errors.delete(:datacenter)
      end
    rescue => e
      errors[:base] << e.message
    end

    def parse_args(args)
      args = args.deep_symbolize_keys

      # convert rails nested_attributes into a plain, symbolized hash
      [:interfaces, :volumes].each do |collection|
        nested_attrs = args.delete("#{collection}_attributes".to_sym)
        args[collection] = nested_attributes_for(collection, nested_attrs) if nested_attrs
      end

      # Backwards compatibility for e.g. API requests.
      # User can set the scsi_controller_type attribute
      # to define a single scsi controller by that type
      if args[:scsi_controller_type].present?
        Foreman::Deprecation.deprecation_warning("1.17", _("SCSI controller type is deprecated. Please change to scsi_controllers"))
        args[:scsi_controller] = {:type => args.delete(:scsi_controller_type)}
      end

      add_cdrom = args.delete(:add_cdrom)
      args[:cdroms] = [new_cdrom] if add_cdrom == '1'

      args.except!(:hardware_version) if args[:hardware_version] == 'Default'

      firmware_type = args.delete(:firmware_type)
      args[:firmware] = firmware_mapping(firmware_type) if args[:firmware] == 'automatic'

      args.reject! { |k, v| v.nil? }
      args
    end

    # Change network IDs for names only at the point of creation, as IDs are
    # used in the UI for select boxes etc.
    def parse_networks(args)
      args = args.deep_dup
      dc_networks = networks
      args["interfaces_attributes"].each do |key, interface|
        # Convert network id into name
        net = dc_networks.detect { |n| [n.id, n.name].include?(interface['network']) }
        raise "Unknown Network ID: #{interface['network']}" if net.nil?
        interface["network"] = net.name
        interface["virtualswitch"] = net.virtualswitch
      end if args["interfaces_attributes"]
      args
    end

    def create_vm(args = { })
      test_connection
      return unless errors.empty?

      args = parse_networks(args)
      args = args.with_indifferent_access
      if args[:provision_method] == 'image'
        clone_vm(args)
      else
        vm = new_vm(args)
        vm.firmware = 'bios' if vm.firmware == 'automatic'
        vm.save
      end
    rescue Fog::Errors::Error => e
      Foreman::Logging.exception("Unhandled VMware error", e)
      destroy_vm vm.id if vm && vm.id
      raise e
    end

    def new_vm(args = {})
      args = parse_args args
      opts = vm_instance_defaults.symbolize_keys.merge(args.symbolize_keys).deep_symbolize_keys
      client.servers.new opts
    end

    def save_vm(uuid, attr)
      vm = find_vm_by_uuid(uuid)
      vm.attributes.merge!(attr.deep_symbolize_keys)
      #volumes are not part of vm.attributes so we have to set them seperately if needed
      if attr.has_key?(:volumes_attributes)
        vm.volumes.each do |vm_volume|
          volume_attrs = attr[:volumes_attributes].values.detect {|vol| vol[:id] == vm_volume.id}
          vm_volume.size_gb = volume_attrs[:size_gb]
        end
      end
      vm.save
    end

    def destroy_vm(uuid)
      find_vm_by_uuid(uuid).destroy :force => true
    rescue ActiveRecord::RecordNotFound
      # if the VM does not exists, we don't really care.
      true
    end

    # === Power on
    #
    # Foreman will try and start this vm after clone in a seperate request.
    #
    def clone_vm(raw_args)
      args = parse_args(raw_args)

      opts = {
        "datacenter" => datacenter,
        "template_path" => args[:image_id],
        "dest_folder" => args[:path],
        "power_on" => false,
        "start" => args[:start],
        "name" => args[:name],
        "numCPUs" => args[:cpus],
        "numCoresPerSocket" => args[:corespersocket],
        "memoryMB" => args[:memory_mb],
        "datastore" => args[:volumes].first[:datastore],
        "storage_pod" => args[:volumes].first[:storage_pod],
        "resource_pool" => [args[:cluster], args[:resource_pool]]
      }

      opts['transform'] = args[:volumes].first[:thin] == 'true' ? 'sparse' : 'flat' unless args[:volumes].empty?

      vm_model = new_vm(raw_args)
      opts['interfaces'] = vm_model.interfaces
      opts['volumes'] = vm_model.volumes
      opts["customization_spec"] = client.cloudinit_to_customspec(args[:user_data]) if args[:user_data]
      client.servers.get(client.vm_clone(opts)['new_vm']['id'])
    end

    def server
      url
    end

    def server=(value)
      self.url = value
    end

    def datacenter
      uuid
    end

    def datacenter=(value)
      self.uuid = value
    end

    def console(uuid)
      vm = find_vm_by_uuid(uuid)
      raise "VM is not running!" unless vm.ready?
      #TOOD port, password
      #NOTE this requires the following port to be open on your ESXi FW
      values = { :port => unused_vnc_port(vm.hypervisor), :password => random_password, :enabled => true }
      vm.config_vnc(values)
      WsProxy.start(:host => vm.hypervisor, :host_port => values[:port], :password => values[:password]).merge(:type => 'vnc')
    end

    def new_interface(attr = { })
      client.interfaces.new attr
    end

    def new_volume(attr = { })
      client.volumes.new attr.merge(:size_gb => 10)
    end

    def new_cdrom(attr = {})
      client.cdroms.new attr
    end

    def new_scsi_controller(attr = {})
      Fog::Compute::Vsphere::SCSIController.new(attr)
    end

    def pubkey_hash
      attrs[:pubkey_hash]
    end

    def pubkey_hash=(key)
      attrs[:pubkey_hash] = key
    end

    def associated_host(vm)
      associate_by("mac", vm.interfaces.map(&:mac))
    end

    def self.provider_friendly_name
      "VMware"
    end

    private

    def dc
      client.datacenters.get(datacenter)
    end

    def update_public_key(options = {})
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

    def unused_vnc_port(ip)
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
        :scsi_controllers => [{ :type => scsi_controller_default_type }],
        :datacenter => datacenter,
        :firmware => 'automatic',
        :boot_order => ['network', 'disk']
      )
    end

    def firmware_mapping(firmware_type)
      return 'efi' if firmware_type == :uefi
      'bios'
    end

    def set_vm_volumes_attributes(vm, vm_attrs)
      volumes = vm.volumes || []
      vm_attrs[:volumes_attributes] = Hash[volumes.each_with_index.map { |volume, idx| [idx.to_s, volume.attributes.merge(:size_gb => volume.size_gb)] }]
      vm_attrs
    end
  end
end
