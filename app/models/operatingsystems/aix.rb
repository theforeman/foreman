class AIX < Operatingsystem
  PXEFILES = {:kernel => "powerpc", :initrd => "initrd"}.freeze

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
