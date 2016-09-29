class AIX < Operatingsystem
  PXEFILES = {:kernel => "powerpc", :initrd => "initrd"}

  # Override the class representation, as this breaks many rails helpers
  def class
    Operatingsystem
  end

  def pxe_type
    "nim"
  end

  def pxedir
    "boot/$arch/loader"
  end

  def url_for_boot(file)
    pxedir + "/" + PXEFILES[file]
  end

  def display_family
    "AIX"
  end
end
