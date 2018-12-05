class Windows < Operatingsystem
  PXEFILES = {:kernel => "wimboot", :initrd => "bootmgr", :bcd => "bcd", :bootsdi => "boot.sdi", :bootwim => "boot.wim"}

  class Jail < Operatingsystem::Jail
    allow :bootfile
  end

  def available_loaders
    self.class.all_loaders
  end

  def pxe_type
    "waik"
  end

  def pxe_prefix(medium_provider)
    medium_provider.interpolate_vars("boot/windows-$arch-#{medium_provider.unique_id}/").to_s.tr(" ", "-")
  end

  def bootfile(medium_provider, type)
    pxe_prefix(medium_provider) + PXEFILES[type.to_sym]
  end

  def boot_files_uri(medium_provider)
    pxe_dir = ""

    PXEFILES.values.collect do |img|
      if img =~ /boot.sdi/i || img =~ /bcd/i
        pxe_dir = "boot"
      elsif img =~ /boot.wim/i
        pxe_dir = "sources"
      else
        pxe_dir = ""
      end

      medium_provider.medium_uri("/#{pxe_dir}/#{img}").normalize
    end
  end

  def display_family
    "Windows"
  end
end
