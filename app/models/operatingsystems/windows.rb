class Windows < Operatingsystem
  PXEFILES = {:kernel => "wimboot", :initrd => "bootmgr", :bcd => "bcd", :bootsdi => "boot.sdi", :bootwim => "boot.wim"}

  def pxe_type
    "waik"
  end

  def pxe_prefix(arch)
    "boot/windows-#{arch}/".tr(" ","-")
  end

  def bootfile arch, type
    pxe_prefix(arch) + eval("#{self.family}::PXEFILES[:#{type}]")
  end

  def boot_files_uri(medium, architecture, host = nil)
    raise ::Foreman::Exception.new(N_("invalid medium for %s"), to_s) unless media.include?(medium)

    pxe_dir = ""

    PXEFILES.values.collect do |img|
      if img =~ /boot.sdi/i || img =~ /bcd/i
        pxe_dir = "boot"
      elsif img =~ /boot.wim/i
        pxe_dir = "sources"
      else
        pxe_dir = ""
      end

      URI.parse("#{medium_vars_to_uri(medium.path, architecture.name, self)}/#{pxe_dir}/#{img}").normalize
    end
  end

  def display_family
    "Windows"
  end
end
