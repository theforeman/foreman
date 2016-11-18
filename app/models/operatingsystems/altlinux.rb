class Altlinux < Operatingsystem
  PXEFILES = {:kernel => "vmlinuz", :initrd => "full.cz" }

  def boot_files_uri(medium, architecture)
    raise ::Foreman::Exception.new(N_("invalid medium for %s"), to_s) unless media.include?(medium)
    raise ::Foreman::Exception.new(N_("invalid architecture for %s"), to_s) unless architectures.include?(architecture)

    PXEFILES.values.collect do |img|
      URI.parse("#{medium_vars_to_uri(medium.path, architecture.name, self)}/syslinux/alt0/#{img}").normalize
    end
  end

  def pxe_type
    "alterator"
  end

  def pxedir
    "boot"
  end

  def url_for_boot(file)
    pxedir + "/" + PXEFILES[file]
  end

  def display_family
    "Altlinux"
  end
end
