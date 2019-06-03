class Xenserver < Operatingsystem
  PXEFILES = {:kernel => "boot/vmlinuz", :initrd => "install.img", :xen => "boot/xen.gz"}
  MBOOT = "boot/pxelinux/mboot.c32"

  def pxe_type
    "xenserver"
  end

  def xen(medium_provider)
    bootfile(medium_provider, :xen)
  end

  def display_family
    "XenServer"
  end

  def bootfile(medium_provider, type)
    pxe_prefix(medium_provider) + "-" + PXEFILES[type.to_sym].split("/")[-1]
  end

  def boot_files_uri(medium_provider)
    PXEFILES.values.push(MBOOT).map do |img|
      medium_provider.medium_uri(img)
    end
  end
end
