class Windows < Operatingsystem
  PXEFILES = {:kernel => "startrom.0", :initrd => "boot.sdi"}

  def class
    Operatingsystem
  end

  def pxe_type
    "waik"
  end

  def pxedir
    "images"
  end

  def url_for_boot(file)
    pxedir + "/" + PXEFILES[file]
  end
end

