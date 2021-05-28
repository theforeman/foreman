require 'fog_extensions/vsphere/mini_servers'
require 'foreman/exception'

begin
  require 'rbvmomi'
rescue LoadError
  # rbvmomi might not be installed
end

module Foreman::Model
  class Vmware < ComputeResource
    include ComputeResourceConsoleCommon
    include ComputeResourceCaching

    validates :user, :password, :server, :datacenter, :presence => true
    validates :display_type, :inclusion => {
      :in => proc { |cr| cr.class.supported_display_types.keys },
      :message => N_('not supported by this compute resource'),
    }

    before_create :update_public_key

    alias_attribute :server, :url
    alias_attribute :datacenter, :uuid

    def self.available?
      Fog::Compute.providers.include?(:vsphere)
    end

    def self.model_name
      ComputeResource.model_name
    end

    def self.supported_display_types
      {
        'vnc' => _('VNC'),
        'vmrc' => _('VMRC'),
      }
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
        super(datacenter: datacenter)
      else
        # VMware server loading is very slow
        # not using FOG models directly to save the time
        # and minimize the amount of time required (as we don't require all attributes by default when listing)
        FogExtensions::Vsphere::MiniServers.new(client, datacenter)
      end
    end

    def available_images
      FogExtensions::Vsphere::MiniServers.new(client, datacenter, templates: true).all
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
      name_sort(client.datacenters.all)
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

    # Params:
    # +name+ identifier of the datastore - its name unique in given vCenter
    def datastore(name)
      cache.cache(:"datastore-#{name}") do
        dc.datastores.get(name)
      end
    end

    # ==== Options
    #
    # * +:cluster_id+ - Limits the datastores in response to the ones available to defined cluster
    def datastores(opts = {})
      cache.cache(cachekey_with_cluster(:datastores, opts[:cluster_id])) do
        name_sort(dc.datastores(cluster: opts[:cluster_id]).all(:accessible => true))
      end
    end

    def storage_pod(name)
      cache.cache(:"storage_pod-#{name}") do
        dc.storage_pods.get(name)
      rescue RbVmomi::VIM::InvalidArgument
        {} # Return an empty storage pod hash if vsphere does not support the feature
      end
    end

    ##
    # Lists storage_pods for datastore/cluster.
    # TODO: fog-vsphere doesn't support cluster base filtering, so the cluser_id is useless for now.
    # ==== Options
    #
    # * +:cluster_id+ - Limits the datastores in response to the ones available to defined cluster
    def storage_pods(opts = {})
      cache.cache(cachekey_with_cluster(:storage_pods, opts[:cluster_id])) do
        name_sort(dc.storage_pods.all(cluster: opts[:cluster_id]))
      rescue RbVmomi::VIM::InvalidArgument
        [] # Return an empty set of storage pods if vsphere does not support the feature
      end
    end

    def available_storage_pods(cluster_id = nil)
      storage_pods(cluster_id: cluster_id)
    end

    def folders
      cache.cache(:folders) do
        dc.vm_folders.sort_by { |f| [f.path, f.name] }
      end
    end

    def networks(opts = {})
      cache_key = opts[:cluster_id].nil? ? :networks : :"networks-#{opts[:cluster_id]}"
      cache.cache(cache_key) do
        name_sort(dc.networks(cluster: opts[:cluster_id]).all(:accessible => true))
      end
    end

    def resource_pools(opts = {})
      cache.cache(:"resource_pools-#{opts[:cluster_id]}") do
        name_sort(cluster(opts[:cluster_id]).resource_pools.all(:accessible => true))
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
      networks(cluster_id: cluster_id)
    end

    def storage_domain(storage_domain)
      datastore(storage_domain)
    end

    def available_storage_domains(cluster_id = nil)
      datastores(cluster_id: cluster_id)
    end

    def available_resource_pools(opts = {})
      resource_pools({ :cluster_id => opts[:cluster_id] })
    end

    def nictypes
      {
        "VirtualE1000" => "E1000",
        "VirtualVmxnet3" => "VMXNET 3",
      }
    end

    def scsi_controller_types
      {
        "VirtualBusLogicController" => "Bus Logic Parallel",
        "VirtualLsiLogicController" => "LSI Logic Parallel",
        "VirtualLsiLogicSASController" => "LSI Logic SAS",
        "ParaVirtualSCSIController" => "VMware Paravirtual",
      }
    end

    def firmware_types
      {
        "automatic" => N_("Automatic"),
        "bios" => N_("BIOS"),
        "efi" => N_("EFI"),
      }
    end

    def disk_mode_types
      {
        "persistent" => _("Persistent"),
        "independent_persistent" => _("Independent - Persistent"),
        "independent_nonpersistent" => _("Independent - Nonpersistent"),
      }
    end

    def boot_devices
      {
        'disk' => _('Harddisk'),
        'cdrom' => _('CD-ROM'),
        'network' => _('Network'),
        'floppy' => _('Floppy'),
      }
    end

    # vSphere guest OS type descriptions
    # list fetched from RbVmomi::VIM::VirtualMachineGuestOsIdentifier.values and
    # https://code.vmware.com/apis/358/vsphere/doc/vim.vm.GuestOsDescriptor.GuestOsIdentifier.html
    def guest_types_descriptions
      {
        "asianux3_64Guest" => "Asianux Server 3 (64-bit)",
        "asianux3Guest" => "Asianux Server 3 (32-bit)",
        "asianux4_64Guest" => "Asianux Server 4 (64-bit)",
        "asianux4Guest" => "Asianux Server 4 (32-bit)",
        "asianux5_64Guest" => "Asianux Server 5 (64-bit)",
        "asianux7_64Guest" => "Asianux Server 7 (64-bit)",
        "asianux8_64Guest" => "Asianux Server 8 (64 bit)",
        "centos6_64Guest" => "CentOS 6 (64-bit)",
        "centos64Guest" => "CentOS 4/5 (64-bit)",
        "centos6Guest" => "CentOS 6 (32-bit)",
        "centos7_64Guest" => "CentOS 7 (64-bit)",
        "centos7Guest" => "CentOS 7 (32-bit)",
        "centos8_64Guest" => "CentOS 8 (64-bit)",
        "centosGuest" => "CentOS 4/5 (32-bit)",
        "coreos64Guest" => "CoreOS Linux (64-bit)",
        "darwin10_64Guest" => "Mac OS 10.6 (64-bit)",
        "darwin10Guest" => "Mac OS 10.6 (32-bit)",
        "darwin11_64Guest" => "Mac OS 10.7 (64-bit)",
        "darwin11Guest" => "Mac OS 10.7 (32-bit)",
        "darwin12_64Guest" => "Mac OS 10.8 (64-bit)",
        "darwin13_64Guest" => "Mac OS 10.9 (64-bit)",
        "darwin14_64Guest" => "Mac OS 10.10 (64-bit)",
        "darwin15_64Guest" => "Mac OS 10.11 (64-bit)",
        "darwin16_64Guest" => "Mac OS 10.12 (64-bit)",
        "darwin17_64Guest" => "macOS 10.13 (64 bit)",
        "darwin18_64Guest" => "macOS 10.14 (64 bit)",
        "darwin64Guest" => "Mac OS 10.5 (64-bit)",
        "darwinGuest" => "Mac OS 10.5 (32-bit)",
        "debian10_64Guest" => "Debian GNU/Linux 10 (64-bit)",
        "debian10Guest" => "Debian GNU/Linux 10 (32-bit)",
        "debian4_64Guest" => "Debian GNU/Linux 4 (64-bit)",
        "debian4Guest" => "Debian GNU/Linux 4 (32-bit)",
        "debian5_64Guest" => "Debian GNU/Linux 5 (64-bit)",
        "debian5Guest" => "Debian GNU/Linux 5 (32-bit)",
        "debian6_64Guest" => "Debian GNU/Linux 6 (64-bit)",
        "debian6Guest" => "Debian GNU/Linux 6 (32-bit)",
        "debian7_64Guest" => "Debian GNU/Linux 7 (64-bit)",
        "debian7Guest" => "Debian GNU/Linux 7 (32-bit)",
        "debian8_64Guest" => "Debian GNU/Linux 8 (64-bit)",
        "debian8Guest" => "Debian GNU/Linux 8 (32-bit)",
        "debian9_64Guest" => "Debian GNU/Linux 9 (64-bit)",
        "debian9Guest" => "Debian GNU/Linux 9 (32-bit)",
        "dosGuest" => "Microsoft MS-DOS.",
        "eComStation2Guest" => "eComStation 2.0",
        "eComStationGuest" => "eComStation 1.x",
        "fedora64Guest" => "Fedora Linux (64-bit)",
        "fedoraGuest" => "Fedora Linux (32-bit)",
        "freebsd64Guest" => "FreeBSD (64-bit)",
        "freebsdGuest" => "FreeBSD (32-bit)",
        "freebsd11_64Guest" => "FreeBSD 11 x64",
        "freebsd11Guest" => "FreeBSD 11",
        "freebsd12_64Guest" => "FreeBSD 12 x64",
        "freebsd12Guest" => "FreeBSD 12",
        "genericLinuxGuest" => "Other Linux",
        "mandrakeGuest" => "Mandrake Linux",
        "mandriva64Guest" => "Mandriva Linux (64-bit)",
        "mandrivaGuest" => "Mandriva Linux (32-bit)",
        "netware4Guest" => "Novell NetWare 4",
        "netware5Guest" => "Novell NetWare 5.1",
        "netware6Guest" => "Novell NetWare 6.x",
        "nld9Guest" => "Novell Linux Desktop 9",
        "oesGuest" => "Open Enterprise Server",
        "openServer5Guest" => "SCO OpenServer 5",
        "openServer6Guest" => "SCO OpenServer 6",
        "opensuse64Guest" => "OpenSUSE Linux (64-bit)",
        "opensuseGuest" => "OpenSUSE Linux (32-bit)",
        "oracleLinux6_64Guest" => "Oracle 6 (64-bit)",
        "oracleLinux64Guest" => "Oracle Linux 4/5 (64-bit)",
        "oracleLinux6Guest" => "Oracle 6 (32-bit)",
        "oracleLinux7_64Guest" => "Oracle 7 (64-bit)",
        "oracleLinux7Guest" => "Oracle 7 (32-bit)",
        "oracleLinux8_64Guest" => "Oracle 8 (64-bit)",
        "oracleLinuxGuest" => "Oracle Linux 4/5",
        "os2Guest" => "IBM OS/2",
        "other24xLinux64Guest" => "Linux 2.4x Kernel (64-bit)",
        "other24xLinuxGuest" => "Linux 2.4x Kernel (32-bit)",
        "other26xLinux64Guest" => "Linux 2.6x Kernel (64-bit)",
        "other26xLinuxGuest" => "Linux 2.6x Kernel (32-bit)",
        "other3xLinux64Guest" => "Linux 3.x Kernel (64-bit)",
        "other3xLinuxGuest" => "Linux 3.x Kernel (32-bit)",
        "other4xLinux64Guest" => "Linux 4.x Kernel (64 bit)",
        "other4xLinuxGuest" => " Linux 4.x Kernel",
        "otherGuest" => "Other Operating System (32-bit)",
        "otherGuest64" => "Other Operating System (64-bit)",
        "otherLinux64Guest" => "Linux (64-bit)",
        "otherLinuxGuest" => "Linux 2.2x Kernel (32-bit)",
        "redhatGuest" => "Red Hat Linux 2.1",
        "rhel2Guest" => "Red Hat Enterprise Linux 2",
        "rhel3_64Guest" => "Red Hat Enterprise Linux 3 (64-bit)",
        "rhel3Guest" => "Red Hat Enterprise Linux 3 (32-bit)",
        "rhel4_64Guest" => "Red Hat Enterprise Linux 4 (64-bit)",
        "rhel4Guest" => "Red Hat Enterprise Linux 4 (32-bit)",
        "rhel5_64Guest" => "Red Hat Enterprise Linux 5 (64-bit)",
        "rhel5Guest" => "Red Hat Enterprise Linux 5 (32-bit)",
        "rhel6_64Guest" => "Red Hat Enterprise Linux 6 (64-bit)",
        "rhel6Guest" => "Red Hat Enterprise Linux 6 (32-bit)",
        "rhel7_64Guest" => "Red Hat Enterprise Linux 7 (64-bit)",
        "rhel7Guest" => "Red Hat Enterprise Linux 7 (32-bit)",
        "rhel8_64Guest" => "Red Hat Enterprise Linux 8 (64 bit)",
        "sjdsGuest" => "Sun Java Desktop System",
        "sles10_64Guest" => "Suse Linux Enterprise Server 10 (64-bit)",
        "sles10Guest" => "Suse Linux Enterprise Server 10 (32-bit)",
        "sles11_64Guest" => "Suse Linux Enterprise Server 11 (64-bit)",
        "sles11Guest" => "Suse Linux Enterprise Server 11 (32-bit)",
        "sles12_64Guest" => "Suse Linux Enterprise Server 12 (64-bit)",
        "sles12Guest" => "Suse Linux Enterprise Server 12 (32-bit)",
        "sles15_64Guest" => "Suse Linux Enterprise Server 15 (64 bit)",
        "sles64Guest" => "Suse Linux Enterprise Server 9 (64-bit)",
        "slesGuest" => "Suse Linux Enterprise Server 9 (32-bit)",
        "solaris10_64Guest" => "Solaris 10 (64-bit)",
        "solaris10Guest" => "Solaris 10 (32-bit)",
        "solaris11_64Guest" => "Solaris 11 (64-bit)",
        "solaris6Guest" => "Solaris 6",
        "solaris7Guest" => "Solaris 7",
        "solaris8Guest" => "Solaris 8",
        "solaris9Guest" => "Solaris 9",
        "suse64Guest" => "Suse Linux (64-bit)",
        "suseGuest" => "Suse Linux (32-bit)",
        "turboLinux64Guest" => "Turbolinux (64-bit)",
        "turboLinuxGuest" => "Turbolinux (32-bit)",
        "ubuntu64Guest" => "Ubuntu Linux (64-bit)",
        "ubuntuGuest" => "Ubuntu Linux (32-bit)",
        "unixWare7Guest" => "SCO UnixWare 7",
        "vmkernel5Guest" => "VMware ESX 5",
        "vmkernel65Guest" => "VMware ESX 6.5",
        "vmkernel6Guest" => "VMware ESX 6",
        "vmkernelGuest" => "VMware ESX 4",
        "vmwarePhoton64Guest" => "VMware Photon (64-bit)",
        "win2000AdvServGuest" => "Microsoft Windows 2000 Advanced Server",
        "win2000ProGuest" => "Microsoft Windows 2000 Professional",
        "win2000ServGuest" => "Microsoft Windows 2000 Server",
        "win31Guest" => "Microsoft Windows 3.1",
        "win95Guest" => "Microsoft Windows 95",
        "win98Guest" => "Microsoft Windows 98",
        "windows7_64Guest" => "Microsoft Windows 7 (64-bit)",
        "windows7Guest" => "Microsoft Windows 7 (32-bit)",
        "windows7Server64Guest" => "Microsoft Windows Server 2008 R2 (64-bit)",
        "windows8_64Guest" => "Microsoft Windows 8 (64-bit)",
        "windows8Guest" => "Microsoft Windows 8 (32-bit)",
        "windows8Server64Guest" => "Microsoft Windows Server 2012 (64 bit)",
        "windows9_64Guest" => "Microsoft Windows 10 (64-bit)",
        "windows9Guest" => "Microsoft Windows 10 (32-bit)",
        "windows9Server64Guest" => "Microsoft Windows Server 2016 (64-bit)",
        "windowsHyperVGuest" => "Microsoft Windows Hyper-V",
        "winLonghorn64Guest" => "Microsoft Windows Longhorn (64-bit)",
        "winLonghornGuest" => "Microsoft Windows Longhorn (32-bit)",
        "winMeGuest" => "Microsoft Windows Millenium Edition",
        "winNetBusinessGuest" => "Microsoft Windows Small Business Server 2003",
        "winNetDatacenter64Guest" => "Microsoft Windows Server 2003, Datacenter Edition (64-bit)",
        "winNetDatacenterGuest" => "Microsoft Windows Server 2003, Datacenter Edition (32-bit)",
        "winNetEnterprise64Guest" => "Microsoft Windows Server 2003, Enterprise Edition (64-bit)",
        "winNetEnterpriseGuest" => "Microsoft Windows Server 2003, Enterprise Edition (32-bit)",
        "winNetStandard64Guest" => "Microsoft Windows Server 2003, Standard Edition (64-bit)",
        "winNetStandardGuest" => "Microsoft Windows Server 2003, Standard Edition (32-bit)",
        "winNetWebGuest" => "Microsoft Windows Server 2003, Web Edition",
        "winNTGuest" => "Microsoft Windows NT 4",
        "winVista64Guest" => "Microsoft Windows Vista (64-bit)",
        "winVistaGuest" => "Microsoft Windows Vista",
        "winXPHomeGuest" => "Microsoft Windows XP Home Edition",
        "winXPPro64Guest" => "Microsoft Windows XP Professional Edition (64-bit)",
        "winXPProGuest" => "Microsoft Windows XP Professional (32-bit)",
      }
    end

    def guest_types
      types = { }
      ::RbVmomi::VIM::VirtualMachineGuestOsIdentifier.values.compact.each do |v|
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
        'vmx-17' => '17 (ESXi 7.0)',
        'vmx-15' => '15 (ESXi 6.7 U2)',
        'vmx-14' => '14 (ESXi 6.7)',
        'vmx-13' => '13 (ESXi 6.5)',
        'vmx-11' => '11 (ESXi 6.0)',
        'vmx-10' => '10 (ESXi 5.5)',
        'vmx-09' => '9 (ESXi 5.1)',
        'vmx-08' => '8 (ESXi 5.0)',
        'vmx-07' => '7 (ESX/ESXi 4.x)',
        'vmx-04' => '4 (ESX/ESXi 3.5)',
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

      # see #26402 - consume scsi_controller_type from hammer as a default scsi type
      scsi_type = args.delete(:scsi_controller_type)
      args[:scsi_controllers] ||= [{ type: scsi_type }] if scsi_controller_types.key?(scsi_type)

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
      args["interfaces_attributes"]&.each do |key, interface|
        # Consolidate network to network id
        net = dc_networks.detect { |n| n.id == interface['network'] }
        net ||= dc_networks.detect { |n| n.name == interface['network'] }
        raise "Unknown Network ID: #{interface['network']}" if net.nil?
        interface["network"] = net.id
        interface["virtualswitch"] = net.virtualswitch
      end
      args
    end

    def create_vm(args = { })
      vm = nil
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
    rescue Fog::Vsphere::Compute::NotFound => e
      Foreman::Logging.exception('Caught VMware error', e)
      raise ::Foreman::WrappedException.new(
        e,
        N_(
          'Foreman could not find a required vSphere resource. Check if Foreman has the required permissions and the resource exists. Reason: %s'
        ) % e.message
      )
    rescue Fog::Errors::Error => e
      Foreman::Logging.exception("Unhandled VMware error", e)
      destroy_vm(vm.id) if vm&.id
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
      # volumes are not part of vm.attributes so we have to set them seperately if needed
      if attr.has_key?(:volumes_attributes)
        vm.volumes.each do |vm_volume|
          volume_attrs = attr[:volumes_attributes].values.detect { |vol| vol[:id] == vm_volume.id }

          next unless volume_attrs.present?

          vm_volume.size_gb = volume_attrs[:size_gb] if volume_attrs[:size_gb].present?
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
        "datastore" => args[:volumes].empty? ? nil : args[:volumes].first[:datastore],
        "storage_pod" => args[:volumes].empty? ? nil : args[:volumes].first[:storage_pod],
        "resource_pool" => [args[:cluster], args[:resource_pool]],
        "boot_order" => [:disk],
        "annotation" => args[:annotation],
      }

      opts['transform'] = (args[:volumes].first[:thin] == 'true') ? 'sparse' : 'flat' unless args[:volumes].empty?

      vm_model = new_vm(raw_args)
      opts['interfaces'] = vm_model.interfaces
      opts['volumes'] = vm_model.volumes
      if args[:user_data] && valid_cloudinit_for_customspec?(args[:user_data])
        opts["customization_spec"] = client.cloudinit_to_customspec(args[:user_data])
        opts["extraConfig"] = opts["customization_spec"]["extraConfig"] if opts["customization_spec"].key?("extraConfig")
      end
      client.servers.get(client.vm_clone(opts)['new_vm']['id'])
    end

    def console(uuid)
      vm = find_vm_by_uuid(uuid)
      raise Foreman::Exception, N_('The console is not available because the VM is not powered on') unless vm.ready?

      case display_type
      when 'vmrc'
        vmrc_console(vm)
      else
        vnc_console(vm)
      end
    end

    def vnc_console(vm)
      values = { :port => unused_vnc_port(vm.hypervisor), :password => random_password, :enabled => true }
      vm.config_vnc(values)
      WsProxy.start(:host => vm.hypervisor, :host_port => values[:port], :password => values[:password]).merge(:type => 'vnc')
    end

    def vmrc_console(vm)
      {
        :name => vm.name,
        :console_url => build_vmrc_uri(server, vm.mo_ref, client.connection.serviceContent.sessionManager.AcquireCloneTicket),
        :type => 'vmrc',
      }
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
      Fog::Vsphere::Compute::SCSIController.new(attr)
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

    def display_type
      attrs[:display] || 'vmrc'
    end

    def display_type=(type)
      attrs[:display] = type.downcase
    end

    def humanized_display_type
      self.class.supported_display_types[display_type]
    end

    def self.provider_friendly_name
      "VMware"
    end

    def vm_compute_attributes(vm)
      vm_attrs = super
      dc_networks = networks
      interfaces = vm.interfaces || []
      vm_attrs[:interfaces_attributes] = interfaces.each_with_index.each_with_object({}) do |(interface, index), hsh|
        network = dc_networks.detect { |n| [n.id, n.name].include?(interface.network) }
        raise Foreman::Exception.new(N_("Could not find network %s on VMWare compute resource"), interface.network) unless network
        interface_attrs = {}
        interface_attrs[:compute_attributes] = {}
        interface_attrs[:mac] = interface.mac
        interface_attrs[:compute_attributes][:network] = network.name
        interface_attrs[:compute_attributes][:type] = interface.type.to_s.split('::').last
        hsh[index.to_s] = interface_attrs
      end
      vm_attrs[:scsi_controllers] = vm.scsi_controllers.map do |controller|
        controller.attributes
      end
      vm_attrs
    end

    def normalize_vm_attrs(vm_attrs)
      normalized = slice_vm_attributes(vm_attrs, ['cpus', 'firmware', 'guest_id', 'annotation', 'resource_pool_id', 'image_id'])

      normalized['cores_per_socket'] = vm_attrs['corespersocket']
      normalized['memory'] = vm_attrs['memory_mb'].nil? ? nil : (vm_attrs['memory_mb'].to_i * 1024)

      normalized['folder_path'] = vm_attrs['path']
      normalized['folder_name'] = folders.detect { |f| f.path == normalized['folder_path'] }.try(:name)

      normalized['cluster_id'] = available_clusters.detect { |c| c.name == vm_attrs['cluster'] }.try(:id)
      normalized['cluster_name'] = vm_attrs['cluster']
      normalized['cluster_name'] = nil if normalized['cluster_name'].empty?

      if normalized['cluster_name']
        normalized['resource_pool_id'] = resource_pools(:cluster_id => normalized['cluster_name']).detect { |p| p.name == vm_attrs['resource_pool'] }.try(:id)
      end
      normalized['resource_pool_name'] = vm_attrs['resource_pool']
      normalized['resource_pool_name'] = nil if normalized['resource_pool_name'].empty?

      normalized['guest_name'] = guest_types[vm_attrs['guest_id']]

      normalized['hardware_version_id'] = vm_attrs['hardware_version']
      normalized['hardware_version_name'] = vm_hw_versions[vm_attrs['hardware_version']]

      normalized['memory_hot_add_enabled'] = to_bool(vm_attrs['memoryHotAddEnabled'])
      normalized['cpu_hot_add_enabled'] = to_bool(vm_attrs['cpuHotAddEnabled'])
      normalized['add_cdrom'] = to_bool(vm_attrs['add_cdrom'])

      normalized['image_name'] = images.find_by(:uuid => vm_attrs['image_id']).try(:name)

      scsi_controllers = vm_attrs['scsi_controllers'] || {}
      normalized['scsi_controllers'] = scsi_controllers.map.with_index do |ctrl, idx|
        [idx.to_s, ctrl]
      end.to_h

      stores = datastores
      volumes_attributes = vm_attrs['volumes_attributes'] || {}
      normalized['volumes_attributes'] = volumes_attributes.each_with_object({}) do |(key, vol), volumes|
        volumes[key] = slice_vm_attributes(vol, ['name', 'mode'])

        volumes[key]['controller_key'] = vol['controller_key']
        volumes[key]['thin'] = to_bool(vol['thin'])
        volumes[key]['eager_zero'] = to_bool(vol['eager_zero'])
        volumes[key]['size'] = memory_gb_to_bytes(vol['size_gb']).to_s
        if vol['datastore'].empty?
          volumes[key]['datastore_id'] = volumes[key]['datastore_name'] = nil
        else
          volumes[key]['datastore_name'] = vol['datastore']
          volumes[key]['datastore_id'] = stores.detect { |s| s.name == vol['datastore'] }.try(:id)
        end
      end

      interfaces_attributes = vm_attrs['interfaces_attributes'] || {}
      normalized['interfaces_attributes'] = interfaces_attributes.inject({}) do |interfaces, (key, nic)|
        interfaces.update(key => { 'type_id' => nic['type'],
                                   'type_name' => nictypes[nic['type']],
                                   'network_id' => nic['network'],
                                   'network_name' => networks.detect { |n| n.id == nic['network'] }.try(:name),
                                 })
      end

      normalized
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
          N_("The remote system presented a public key with hash %s but we're expecting a different hash. If you are sure the remote system is authentic, go to the compute resource edit page, press the 'Test Connection' or 'Load Datacenters' button and submit"), Regexp.last_match(1))
      elsif e.message =~ /Cannot complete login due to an incorrect user name or password./
        raise Foreman::UsernameOrPasswordException.new(
          N_("Can not load datacenters due to an incorrect user name or password."))
      else
        raise e
      end
    end

    def unused_vnc_port(ip)
      10.times do
        port   = rand(5901..5964)
        unused = (TCPSocket.connect(ip, port).close rescue true)
        return port if unused
      end
      raise "no unused port found"
    end

    def vm_instance_defaults
      super.merge(
        :memory_mb  => 2048,
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

    def build_vmrc_uri(host, vmid, ticket)
      uri = URI::Generic.build(:scheme   => 'vmrc',
                               :userinfo => "clone:#{ticket}",
                               :host     => host,
                               :port     => 443,
                               :path     => '/',
                               :query    => "moid=#{vmid}").to_s
      # VMRC doesn't like brackets around IPv6 addresses
      uri.sub(/(.*)\[/, '\1').sub(/(.*)\]/, '\1')
    end

    def valid_cloudinit_for_customspec?(cloudinit)
      parsed = YAML.load(cloudinit)
      return false if parsed.nil?
      return true if parsed.is_a?(Hash)
      raise Foreman::Exception.new('The user-data template must be a hash in YAML format for VM customization to work.')
    rescue Psych::SyntaxError => e
      Foreman::Logging.exception('Failed to parse user-data template', e)
      raise Foreman::Exception.new('The user-data template must be valid YAML for VM customization to work.')
    end

    def cachekey_with_cluster(key, cluster_id = nil)
      cluster_id.nil? ? key.to_sym : "#{key}-#{cluster_id}".to_sym
    end
  end
end
