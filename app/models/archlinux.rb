class Archlinux < Operatingsystem

  PXEFILES = {:kernel => "linux", :initrd => "initrd"}

  # Simple output of the media url
  def mediumpath host
    medium_uri(host).to_s
  end

  # Override the class representation, as this breaks many rails helpers
  def class
    Operatingsystem
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

end
