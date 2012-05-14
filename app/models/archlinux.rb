class Archlinux < Operatingsystem

  PXEFILES = {:kernel => "linux", :initrd => "initrd"}

  # Override the class representation, as this breaks many rails helpers
  def class
    Operatingsystem
  end

  def pxe_type
    "aix" # Fairly pointless as we have to set up NBD separately for now
  end

  def pxedir
    "boot/$arch/loader"
  end

  def url_for_boot(file)
    pxedir + "/" + PXEFILES[file]
  end

end
