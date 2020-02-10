class Archlinux < Operatingsystem
  PXEFILES = {:kernel => "linux", :initrd => "initrd"}

  # Simple output of the media url
  def mediumpath(medium_provider)
    medium_provider.medium_uri.to_s
  end

  def pxe_type
    "aif"
  end

  def pxedir(medium_provider = nil)
    "boot/$arch/loader"
  end

  def display_family
    "Arch Linux"
  end
end
