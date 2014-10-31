class Coreos < Operatingsystem
  PXEFILES = {:kernel => 'coreos_production_pxe.vmlinuz', :initrd => 'coreos_production_pxe_image.cpio.gz'}

  def pxe_type
    'coreos'
  end

  def url_for_boot(file)
    PXEFILES[file]
  end

  def pxedir
    'amd64-usr/' + [self.major, self.minor ].compact.join('.')
  end

  def display_family
    'CoreOS'
  end

  def boot_files_uri(medium, architecture, host = nil)
    super(medium, architecture, host)
  end

  # Does this OS family use release_name in its naming scheme
  def use_release_name?
    true
  end

  def self.model_name
    superclass.model_name
  end

end