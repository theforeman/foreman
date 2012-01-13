class Microsoft < Operatingsystem

  PXEFILES = {:kernel => "startrom.0", :bcdstore => "BCD", :bootmgr => "bootmgr.exe", :bootsdi => "boot.sdi", :winimage => "winpe.wim"}
  
  def class
    Operatingsystem
  end

  def pxe_type
    "unattended"
  end

  def pxedir
    "images"
  end

  def url_for_boot(file)
    pxedir + "/" + PXEFILES[file]
  end
end
  
