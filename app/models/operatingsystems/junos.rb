class Junos < Operatingsystem
  # We don't fetch any files here.
  PXEFILES = {}

  # Simple output of the media url
  def mediumpath(host)
    medium_uri(host).to_s
  end

  def class
    Operatingsystem
  end

  # The PXE type to use when generating actions and evaluating attributes. jumpstart, kickstart and preseed are currently supported.
  def pxe_type
    "ZTP"
  end

  # The variant to use when communicating with the proxy. Syslinux are pxegrub currently supported
  def pxe_variant
    "ZTP"
  end

  # The kind of PXE configuration template used. PXELinux and PXEGrub are currently supported
  def template_kind
    "ZTP"
  end

  def pxedir
    "boot/$arch/images"
  end

  def url_for_boot(file)
    pxedir + "/" + PXEFILES[file]
  end

  #handle things like gpxelinux/ gpxe / pxelinux here
  def boot_filename(host = nil)
    "ztp.cfg/"+host.mac.gsub(/:/,"").upcase
  end

  def kernel(arch)
    "memdisk"
  end

  def initrd(arch)
    "none"
  end

  def display_family
    "Junos"
  end

end
