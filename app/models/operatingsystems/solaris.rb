class Solaris < Operatingsystem
  PXEFILES = {:initrd => "x86.miniroot", :kernel => "multiboot"}

  def file_prefix
    to_s.gsub(/[\s\(\)]/, "-").gsub("--", "-").gsub(/-\Z/, "")
  end

  # sets the prefix for the tftp files based on the OS
  def pxe_prefix(_medium_provider)
    "boot/#{file_prefix}"
  end

  def to_label
    "#{super}#{(' (' + release_name + ')') unless release_name.empty?}"
  end

  # The PXE type to use when generating actions and evaluating attributes. jumpstart, kickstart and preseed are currently supported.
  def pxe_type
    "jumpstart"
  end

  def available_loaders
    ["None"]
  end

  def dhcp_record_type
    Net::DHCP::SparcRecord
  end

  def template_kinds
    ["PXEGrub"]
  end

  def pxedir(medium_provider = nil)
    "Solaris_$minor/Tools/Boot"
  end

  def boot_filename(host)
    if host.jumpstart?
      "Solaris-#{major}.#{minor}-#{release_name}-#{host.model.hardware_model}-inetboot"
    else
      "Solaris-5.#{minor}-#{release_name}-pxegrub"
    end
  end

  def pxeconfig_default
    "boot/grub/menu.lst"
  end

  # If this OS family requires access to its media via NFS
  def self.require_nfs_access_to_medium
    true
  end

  # Calculates the media's path in relation to the domain and convert host to an IP
  def media_path(medium, domain)
    resolv_nfs_path medium.media_host, medium.media_dir, domain
  end

  # Calculates the jumpstart's path in relation to the domain and convert host to an IP
  def jumpstart_path(medium, domain)
    resolv_nfs_path medium.jumpstart_host, medium.jumpstart_dir, domain
  end

  # Does this OS family support a build variant that is constructed from a prebuilt archive
  def supports_image
    true
  end

  def image_extension
    "flar"
  end

  # Does this OS family use release_name in its naming scheme
  def use_release_name?
    true
  end

  # Helper text shown next to release name
  def release_name_help
    _('auxiliary field')
  end

  def jumpstart_params(host, vendor)
    medium_provider = Foreman::Plugin.medium_providers_registry.find_provider(host)
    # root server and install server are always the same under Foreman
    server_name = host.medium.media_host
    server_ip   = host.domain.resolver.getaddress(server_name).to_s
    jpath       = jumpstart_path host.medium, host.domain
    ipath       = medium_provider.interpolate_vars(host.medium.media_dir).to_s

    {
      :vendor => "<#{vendor}>",
      :root_server_ip        => server_ip,                              # 192.168.216.241
      :root_server_hostname  => server_name,                            # mediahost
      :root_path_name        => "#{ipath}/Solaris_#{minor}/Tools/Boot", # /vol/solgi_5.10/sol10_hw0910/Solaris_10/Tools/Boot
      :install_server_ip     => server_ip,                              # 192.168.216.241
      :install_server_name   => server_name.split('.').first,           # mediahost
      :install_path          => ipath,                                  # /vol/solgi_5.10/sol10_hw0910
      :sysid_server_path     => "#{jpath}/sysidcfg/sysidcfg_primary",   # 192.168.216.241:/vol/jumpstart/sysidcfg/sysidcfg_primary
      :jumpstart_server_path => jpath, # 192.168.216.241:/vol/jumpstart
    }
  end

  def display_family
    "Solaris"
  end

  private

  def resolv_nfs_path(host, dir, domain)
    host += ".#{domain.name}" unless host =~ /\./
    # If host is already an IP then this works fine
    ip = domain.resolver.getaddress(host)
    "#{ip}:#{dir}"
  end
end
