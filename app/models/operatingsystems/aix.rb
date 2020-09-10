class AIX < Operatingsystem
  PXEFILES = {:kernel => "powerpc", :initrd => "initrd"}

  def pxe_type
    "nim"
  end

  def pxedir(medium_provider = nil)
    "boot/$arch/loader"
  end

  def display_family
    "AIX"
  end
end
