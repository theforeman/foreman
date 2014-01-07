class Suse < Operatingsystem

  PXEFILES = {:kernel => "linux", :initrd => "initrd"}

  def pxe_type
    "yast"
  end

  def pxedir
    "boot/$arch/loader"
  end

  def url_for_boot(file)
    pxedir + "/" + PXEFILES[file]
  end

  def display_family
    "SUSE"
  end

  def self.model_name
    superclass.model_name
  end

end
