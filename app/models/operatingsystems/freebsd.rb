class Freebsd < Operatingsystem
  # We don't fetch any PXEFILES!
  # Please copy your mfsbsd boot image into the tftp area.
  #
  # -as kernel we will use memdisk
  # -as initrd we will use your custom FreeBSD-<arch>-<version>-mfs.img in boot
  PXEFILES = {}

  # Simple output of the media url
  def mediumpath(host)
    medium_uri(host).to_s.gsub("x86_64","amd64")
  end

  def pxe_type
    "memdisk"
  end

  def pxedir
    "boot/$arch/images"
  end

  def url_for_boot(file)
    pxedir + "/" + PXEFILES[file]
  end

  def kernel(arch)
    "memdisk"
  end

  def initrd(arch)
    "boot/FreeBSD-#{arch}-#{release}-mfs.img"
  end

  def self.model_name
    superclass.model_name
  end

  def display_family
    "FreeBSD"
  end
end
