class Debian < Operatingsystem

  PXEFILES = {:kernel => "linux", :initrd => "initrd.gz"}

  def preseed_server host
    media_uri(host).select(:host, :port).compact.join(':')
  end

  def preseed_path host
    media_uri(host).select(:path, :query).compact.join('?')
  end

  # Override the class representation, as this breaks many rails helpers
  def class
    Operatingsystem
  end

  def boot_files_uri(media, architecture)
    raise "invalid media for #{to_s}" unless medias.include?(media)
    raise "invalid architecture for #{to_s}" unless architectures.include?(architecture)

    # Debian stores x86_64 arch is amd64
    arch = architecture.to_s.gsub("x86_64","amd64")
    pxe_dir = "dists/#{release_name}/main/installer-#{arch}/current/images/netboot/#{guess_os}-installer/#{arch}"

    PXEFILES.values.collect do |img|
      URI.parse("#{media_vars_to_uri(media.path, architecture.name, self)}/#{pxe_dir}/#{img}").normalize
    end
  end

  def pxe_type
    "preseed"
  end

  private

  # tries to guess if this an ubuntu or a debian os
  def guess_os
    name =~ /ubuntu/i ? "ubuntu" : "debian"
  end

end
