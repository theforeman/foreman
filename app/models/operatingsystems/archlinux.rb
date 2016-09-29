class Archlinux < Operatingsystem
  PXEFILES = {:kernel => "linux", :initrd => "initrd"}

  class << self
    delegate :model_name, :to => :superclass
  end

  # Simple output of the media url
  def mediumpath(host)
    medium_uri(host).to_s
  end

  def pxe_type
    "aif"
  end

  def pxedir
    "boot/$arch/loader"
  end

  def url_for_boot(file)
    pxedir + "/" + PXEFILES[file]
  end

  def display_family
    "Arch Linux"
  end
end
