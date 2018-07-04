class Junos < Operatingsystem
  # We don't fetch any files here.
  PXEFILES = {}

  # Simple output of the media url
  def mediumpath(medium_provider)
    medium_provider.medium_uri.to_s
  end

  # The PXE type to use when generating actions and evaluating attributes. jumpstart, kickstart and preseed are currently supported.
  def pxe_type
    "ZTP"
  end

  def available_loaders
    ["None"]
  end

  def template_kinds
    ["ZTP"]
  end

  def pxedir
    "boot/$arch/images"
  end

  def boot_filename(host = nil)
    "ztp.cfg/" + host.mac.delete(':').upcase
  end

  def kernel(_medium_provider)
    "memdisk"
  end

  def initrd(_medium_provider)
    "none"
  end

  def display_family
    "Junos"
  end
end
