class Altlinux < Operatingsystem
  PXEFILES = {:kernel => "vmlinuz", :initrd => "full.cz" }

  def boot_files_uri(medium_provider)
    PXEFILES.values.collect do |img|
      URI.parse("#{medium_provider.medium_uri}/syslinux/alt0/#{img}").normalize
    end
  end

  def mediumpath(medium_provider)
    medium_provider.medium_uri.to_s
  end

  def pxe_type
    "alterator"
  end

  def pxedir
    "boot"
  end

  def display_family
    "Altlinux"
  end
end
