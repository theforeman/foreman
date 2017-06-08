class Vsphere < Operatingsystem
  PXEFILES = {:kernel => "mboot.c32", :initrd => ""}

  class << self
    delegate :model_name, :to => :superclass
  end

  def mediumpath(host)
    medium_uri(host).to_s
  end

  def pxe_type
    "kickstart"
  end

  def url_for_boot(file)
    PXEFILES[file]
  end

  def display_family
    "vSphere"
  end
end
