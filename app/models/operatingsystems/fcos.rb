class Fcos < Operatingsystem
  #
  # Example PXE URLs:
  # https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/32.20200907.3.0/x86_64/fedora-coreos-32.20200907.3.0-live-kernel-x86_64
  # https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/32.20200907.3.0/x86_64/fedora-coreos-32.20200907.3.0-live-initramfs.x86_64.img
  #
  PXEFILES = {
    kernel: 'fedora-coreos-$major.$minor-live-kernel-$arch',
    initrd: 'fedora-coreos-$major.$minor-live-initramfs.$arch.img',
  }

  def pxe_type
    'fcos'
  end

  def bootfile(medium_provider, type)
    medium_provider.interpolate_vars(super).to_s
  end

  def pxedir(medium_provider = nil)
    medium_provider.interpolate_vars('prod/streams/$release/builds/$major.$minor/$arch').to_s
  end

  def display_family
    'Fedora CoreOS'
  end

  # Does this OS family use release_name in its naming scheme
  def use_release_name?
    true
  end

  # Helper text shown next to major version (do not use i18n)
  def major_version_help
    '32'
  end

  # Helper text shown next to minor version (do not use i18n)
  def minor_version_help
    '20200907.3.0'
  end

  # Helper text shown next to release name (do not use i18n)
  def release_name_help
    'stable, testing, next'
  end
end
