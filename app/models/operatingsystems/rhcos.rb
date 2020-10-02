class Rhcos < Operatingsystem
  #
  # Example PXE URLs:
  # http://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.5/4.5.6/rhcos-installer-kernel-x86_64
  # http://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.5/4.5.6/rhcos-installer-initramfs.x86_64.img
  #
  # Version 4.6+ changed:
  # http://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.6/4.6.1/rhcos-live-initramfs.x86_64.img
  # http://mirror.openshift.com/pub/openshift-v4/x86_64/dependencies/rhcos/4.6/4.6.1/rhcos-live-kernel-x86_64
  PXEFILES = {
    kernel: 'rhcos-live-kernel-$arch',
    initrd: 'rhcos-live-initramfs.$arch.img',
  }

  def pxe_type
    'rhcos'
  end

  def bootfile(medium_provider, type)
    medium_provider.interpolate_vars(super).to_s
  end

  def pxedir(medium_provider = nil)
    medium_provider.interpolate_vars('pub/openshift-v$major/$arch/dependencies/rhcos/$major.$minor/$major.$minor.$release').to_s
  end

  def display_family
    'Red Hat CoreOS'
  end

  # Does this OS family use release_name in its naming scheme
  def use_release_name?
    true
  end

  # Helper text shown next to major version (do not use i18n)
  def major_version_help
    '4 (*X*.Y.Z)'
  end

  # Helper text shown next to minor version (do not use i18n)
  def minor_version_help
    '5 (X.*Y*.Z)'
  end

  # Helper text shown next to release name (do not use i18n)
  def release_name_help
    '6 (X.Y.*Z*)'
  end
end
