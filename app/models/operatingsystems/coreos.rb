class Coreos < Operatingsystem
  PXEFILES = {:kernel => 'coreos_production_pxe.vmlinuz', :initrd => 'coreos_production_pxe_image.cpio.gz'}

  def pxe_type
    'coreos'
  end

  def mediumpath(host)
    medium_uri(host, "#{host.medium.path}/#{host.architecture.name}-usr").to_s.gsub('x86_64','amd64')
  end

  def url_for_boot(file)
    PXEFILES[file]
  end

  def pxedir
    '$arch/$version'
  end

  def boot_files_uri(medium, architecture, host = nil)
    super(medium, architecture, host).each{ |img_uri| img_uri.path = img_uri.path.gsub('x86_64','amd64-usr') }
  end

  def display_family
    'CoreOS'
  end

  # Does this OS family use release_name in its naming scheme
  def use_release_name?
    true
  end
end
