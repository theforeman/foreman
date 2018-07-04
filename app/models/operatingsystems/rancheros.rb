class Rancheros < Operatingsystem
  PXEFILES = {:kernel => 'vmlinuz', :initrd => 'initrd'}

  def pxe_type
    'rancheros'
  end

  def mediumpath(medium_provider)
    ''
  end

  def url_for_boot(file)
    PXEFILES[file]
  end

  def pxedir
    ''
  end

  def boot_files_uri(medium, architecture, host = nil)
    super(medium, architecture, host)
  end

  def display_family
    'RancherOS'
  end
end
