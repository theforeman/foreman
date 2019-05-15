class Coreos < Operatingsystem
  PXEFILES = {:kernel => 'coreos_production_pxe.vmlinuz', :initrd => 'coreos_production_pxe_image.cpio.gz'}

  def pxe_type
    'coreos'
  end

  def mediumpath(medium_provider)
    medium_provider.medium_uri('$arch-usr/') do |vars|
      transform_vars(vars)
    end.to_s
  end

  def pxedir
    '$arch-usr/$version'
  end

  def boot_file_sources(medium_provider, &block)
    super do |vars|
      vars = yield(vars) if block_given?

      transform_vars(vars)
    end
  end

  def display_family
    'CoreOS'
  end

  # Does this OS family use release_name in its naming scheme
  def use_release_name?
    true
  end

  private

  def transform_vars(vars)
    vars[:arch] = vars[:arch].sub('x86_64', 'amd64')
  end
end
