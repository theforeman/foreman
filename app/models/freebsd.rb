class Freebsd < Operatingsystem
  PXEFILES = {:initrd => "mfsbsd.img"}

  def class
    Operatingsystem
  end

  def pxe_type
    "memdisk"
  end

  def pxedir
    "boot/$arch/images"
  end

  def url_for_boot(file)
    pxedir + "/" + PXEFILES[file]
  end

  def kernel arch
    "memdisk"
  end
end
