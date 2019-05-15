class Rancheros < Operatingsystem
  PXEFILES = {:kernel => 'vmlinuz', :initrd => 'initrd'}

  def pxe_type
    'rancheros'
  end

  def mediumpath(medium_provider)
    ''
  end

  def display_family
    'RancherOS'
  end
end
