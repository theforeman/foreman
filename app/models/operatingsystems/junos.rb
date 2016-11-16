class Junos < Operatingsystem
  # We don't fetch any files here.
  PXEFILES = {}

  # Simple output of the media url
  def mediumpath(host)
    medium_uri(host).to_s
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

  def url_for_boot(file)
    pxedir + "/" + PXEFILES[file]
  end

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
