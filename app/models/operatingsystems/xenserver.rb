class Xenserver < Operatingsystem
  PXEFILES = {:kernel => "boot/vmlinuz", :initrd => "install.img", :xen => "boot/xen.gz"}
  MBOOT = "boot/pxelinux/mboot.c32"

  def mediumpath(host)
    medium_uri(host).to_s
  end

  def pxe_type
    "xenserver"
  end

  def pxedir
    ""
  end

  def xen(arch)
    bootfile(arch,:xen)
  end

  def url_for_boot(file)
    pxedir + "/" + PXEFILES[file]
  end

  def display_family
    "XenServer"
  end

  def self.model_name
    superclass.model_name
  end

  def bootfile(arch, type)
    pxe_prefix(arch) + "-" + eval("#{self.family}::PXEFILES[:#{type}]").split("/")[-1]
  end

  def boot_files_uri(medium, architecture, host = nil)
    raise ::Foreman::Exception.new(N_("Invalid medium for %s"), self) unless media.include?(medium)
    raise ::Foreman::Exception.new(N_("Invalid architecture for %s"), self) unless architectures.include?(architecture)
    eval("#{self.family}::PXEFILES").values.push(MBOOT).collect do |img|
      medium_vars_to_uri("#{medium.path}/#{img}", architecture.name, self)
    end
  end
end
