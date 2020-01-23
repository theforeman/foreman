class VRP < Operatingsystem
  PXEFILES = {:core => "firmware.cc", :web => "web.7z"}

  def pxe_prefix(medium_provider)
    "ztp.cfg/images/#{medium_provider.unique_id}/"
  end

  # The PXE type to use when generating actions and evaluating attributes. jumpstart, kickstart and preseed are currently supported.
  def pxe_type
    "ZTP"
  end

  def available_loaders
    ["None"]
  end

  def dhcp_record_type
    Net::DHCP::ZTPRecord
  end

  def template_kinds
    ["ZTP"]
  end

  def pxedir(medium_provider = nil)
    "boot/$arch/images"
  end

  def boot_filename(host = nil)
    "ztp.cfg/" + host.mac.delete(':').upcase + ".cfg"
  end

  def kernel(_medium_provider)
    "memdisk"
  end

  def initrd(_medium_provider)
    "none"
  end

  def display_family
    "VRP"
  end

  def ztp_arguments(host)
    medium_provider = Foreman::Plugin.medium_providers.find_provider host

    {
      :vendor   => "huawei",
      :firmware => {
        :core => "#{pxe_prefix medium_provider}#{PXEFILES[:core]}",
        :web => "#{pxe_prefix medium_provider}#{PXEFILES[:web]}",
      },
    }
  end
end
