class Coreos < Operatingsystem
  #
  # Original CoreOS example PXE URLs:
  # https://stable-temporary-archive.release.core-os.net/amd64-usr/2512.3.0/coreos_production_pxe.vmlinuz
  # https://stable-temporary-archive.release.core-os.net/amd64-usr/2512.3.0/coreos_production_pxe_image.cpio.gz
  #
  # Flatcar example PXE URLs:
  # https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_image.vmlinuz
  # https://stable.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe_image.cpio.gz
  #
  PXEFILES = {
    kernel: 'coreos_production_pxe.vmlinuz',
    initrd: 'coreos_production_pxe_image.cpio.gz',
  }

  def pxe_type
    'coreos'
  end

  def bootfile(medium_provider, type)
    super.sub('coreos_', "#{pxe_file_prefix}_")
  end

  def mediumpath(medium_provider)
    medium_provider.medium_uri('$arch-usr/') do |vars|
      transform_vars(vars)
    end.to_s
  end

  def pxedir(medium_provider = nil)
    if medium_provider&.os_major&.to_s == "0"
      '$arch-usr/current'
    else
      '$arch-usr/$version'
    end
  end

  def boot_file_sources(medium_provider, &block)
    sources = super do |vars|
      vars = yield(vars) if block_given?

      transform_vars(vars)
    end

    sources.transform_values do |url|
      url.sub('/coreos_', "/#{pxe_file_prefix}_")
    end
  end

  def display_family
    'CoreOS'
  end

  # Does this OS family use release_name in its naming scheme
  def use_release_name?
    true
  end

  # Helper text shown next to major version (do not use i18n)
  def major_version_help
    '2512.3 or set to 0 to use current'
  end

  # Helper text shown next to minor version (do not use i18n)
  def minor_version_help
    '0'
  end

  # Helper text shown next to release name (do not use i18n)
  def release_name_help
    'stable, beta, alpha, edge'
  end

  private

  # tries to guess if this a flatcar or original coreos container linux
  def pxe_file_prefix
    (name =~ /flatcar/i) ? 'flatcar' : 'coreos'
  end

  def transform_vars(vars)
    vars[:arch] = vars[:arch].sub('x86_64', 'amd64')
  end
end
