class Debian < Operatingsystem

  PXEFILES = {:kernel => "linux", :initrd => "initrd.gz"}

  def preseed_server(host)
    medium_uri(host).select(:host, :port).compact.join(':')
  end

  def preseed_path(host)
    medium_uri(host).select(:path, :query).compact.join('?')
  end

  def boot_files_uri(medium, architecture, host = nil)
    raise ::Foreman::Exception.new(N_("invalid medium for %s"), to_s) unless media.include?(medium)
    raise ::Foreman::Exception.new(N_("invalid architecture for %s"), to_s) unless architectures.include?(architecture)

    # Debian stores x86_64 arch is amd64
    arch = architecture.to_s.gsub("x86_64","amd64")
    pxe_dir = "dists/#{release_name}/main/installer-#{arch}/current/images/netboot/#{guess_os}-installer/#{arch}"

    PXEFILES.values.collect do |img|
      URI.parse("#{medium_vars_to_uri(medium.path, architecture.name, self)}/#{pxe_dir}/#{img}").normalize
    end
  end

  def pxe_type
    "preseed"
  end

  # Does this OS family use release_name in its naming scheme
  def use_release_name?
    true
  end

  def display_family
    "Debian"
  end

  def self.shorten_description(description)
    return "" if description.blank?
    s=description
    s.gsub!('GNU/Linux','')
    s.gsub!(/\(.+?\)/,'')
    s.squeeze! " "
    s.strip!
    s.blank? ? description : s
  end

  private

  # tries to guess if this an ubuntu or a debian os
  def guess_os
    name =~ /ubuntu/i ? "ubuntu" : "debian"
  end

  def self.model_name
    superclass.model_name
  end

end
