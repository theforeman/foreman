class Windows < Operatingsystem
  PXEFILES = {:kernel => "startrom.0", :initrd => "boot.sdi"}

  def pxe_type
    "waik"
  end

  def pxedir
    "images"
  end

  def url_for_boot(file)
    pxedir + "/" + PXEFILES[file]
  end
  
  def self.model_name
    superclass.model_name
  end

  def self.model_name
    superclass.model_name
  end

  def display_family
    "Windows"
  end
end
