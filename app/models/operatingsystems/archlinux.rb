class Archlinux < Operatingsystem

  PXEFILES = {:kernel => "linux", :initrd => "initrd"}

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

  def self.model_name
    superclass.model_name
  end

end
