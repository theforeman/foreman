class Solaris < Operatingsystem
  PXEFILES = {:initrd => "x86.miniroot", :kernel => "multiboot"}

  def file_prefix
    "#{to_s}".gsub(/[\s\(\)]/,"-").gsub("--", "-").gsub(/-\Z/, "")
  end

  # sets the prefix for the tftp files based on the OS
  def pxe_prefix(architecture=nil)
    "boot/#{file_prefix}"
  end

  def to_label
    "#{super}#{(' (' + release_name + ')') unless release_name.empty?}"
  end

  # The PXE type to use when generating actions and evaluating attributes. jumpstart, kickstart and preseed are currently supported.
  def pxe_type
    "jumpstart"
  end

  # The variant to use when communicating with the proxy. Syslinux are pxegrub currently supported
  def pxe_variant
    "pxegrub"
  end

  # The kind of PXE configuration template used. PXELinux and PXEGrub are currently supported
  def template_kind
    "PXEGrub"
  end

  def pxedir
    "Solaris_#{minor}/Tools/Boot"
  end

  def url_for_boot(file)
    pxedir + "/" + PXEFILES[file]
  end

  def boot_filename system
    #handle things like gpxelinux/ gpxe / pxelinux here
    if system.jumpstart?
      "Solaris-#{major}.#{minor}-#{release_name}-#{system.model.hardware_model}-inetboot"
    else
      "Solaris-5.#{minor}-#{release_name}-pxegrub"
    end
  end

  def pxeconfig_default
    "boot/grub/menu.lst"
  end

  # If this OS family requires access to its media via NFS
  def require_nfs_access_to_medium
    true
  end

  # Calculates the media's path in relation to the domain and convert system to an IP
  def media_path medium, domain
    resolv_nfs_path medium.media_system, medium.media_dir, domain
  end

  # Calculates the jumpstart's path in relation to the domain and convert system to an IP
  def jumpstart_path medium, domain
    resolv_nfs_path medium.jumpstart_system, medium.jumpstart_dir, domain
  end
  # Override the class representation, as this breaks many rails helpers
  def class
    Operatingsystem
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

  def jumpstart_params system, vendor
    # root server and install server are always the same under Foreman
    server_name = system.medium.media_system
    server_ip   = system.domain.resolver.getaddress(server_name).to_s
    jpath       = jumpstart_path system.medium, system.domain
    ipath       = interpolate_medium_vars(system.medium.media_dir, system.architecture.name, self)

    {
      :vendor => "<#{vendor}>",
      :root_server_ip        => server_ip,                              # 192.168.216.241
      :root_server_systemname  => server_name,                            # mediasystem
      :root_path_name        => "#{ipath}/Solaris_#{minor}/Tools/Boot", # /vol/solgi_5.10/sol10_hw0910/Solaris_10/Tools/Boot
      :install_server_ip     => server_ip,                              # 192.168.216.241
      :install_server_name   => server_name,                            # mediasystem
      :install_path          => ipath,                                  # /vol/solgi_5.10/sol10_hw0910
      :sysid_server_path     => "#{jpath}/sysidcfg/sysidcfg_primary",   # 192.168.216.241:/vol/jumpstart/sysidcfg/sysidcfg_primary
      :jumpstart_server_path => jpath,                                  # 192.168.216.241:/vol/jumpstart
    }
  end

  private
  def resolv_nfs_path system, dir, domain
    system = system + ".#{domain.name}" unless system =~ /\./
    # If system is already an IP then this works fine
    ip = domain.resolver.getaddress(system)
    "#{ip}:#{dir}"
  end

end
