class Coreos < Operatingsystem
  PXEFILES = {:kernel => 'coreos_production_pxe.vmlinuz', :initrd => 'coreos_production_pxe_image.cpio.gz'}

  def pxe_type
    'coreos'
  end

  # Simple output of the media url
  def mediumpath(host)
    medium_uri(host, "#{host.medium.path}/amd64-usr").to_s
  end

  def url_for_boot(file)
    PXEFILES[file]
  end

  def pxedir
    'amd64-usr/$version'
  end

  def display_family
    'CoreOS'
  end

  # Does this OS family use release_name in its naming scheme
  def use_release_name?
    true
  end

  def self.model_name
    superclass.model_name
  end

end