class Freebsd < Operatingsystem
  # We don't fetch any PXEFILES!
  # Please copy your mfsbsd boot image into the tftp area.
  #
  # -as kernel we will use memdisk
  # -as initrd we will use your custom FreeBSD-<arch>-<version>-mfs.img in boot
  PXEFILES = {}

  # Simple output of the media url
  def mediumpath(medium_provider)
    medium_provider.to_s do |vars|
      transform_vars(vars)
    end
  end

  def pxe_type
    "memdisk"
  end

  def pxedir
    "boot/$arch/images"
  end

  def kernel(_medium_provider)
    "memdisk"
  end

  def initrd(medium_provider)
    medium_provider.interpolate_vars("boot/FreeBSD-$arch-$release-mfs.img") do |vars|
      transform_vars(vars)
    end
  end

  def display_family
    "FreeBSD"
  end

  private

  def transform_vars(vars)
    vars[:arch] = vars[:arch].sub('x86_64', 'amd64')
  end
end
