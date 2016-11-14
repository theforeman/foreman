class Debian < Operatingsystem
  PXEFILES = {:kernel => "linux", :initrd => "initrd.gz"}

  def pxedir
    'dists/$release/main/installer-$arch/current/images/netboot/' + guess_os + '-installer/$arch'
  end

  def preseed_server(host)
    medium_uri(host).select(:host, :port).compact.join(':')
  end

  def preseed_path(host)
    medium_uri(host).select(:path, :query).compact.join('?')
  end

  def boot_files_uri(medium, architecture, host = nil)
    super(medium, architecture, host).each{ |img_uri| img_uri.path = img_uri.path.gsub('x86_64','amd64') }
  end

  def available_loaders
    self.class.all_loaders
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

  def self.model_name
    superclass.model_name
  end

  private

  # tries to guess if this an ubuntu or a debian os
  def guess_os
    name =~ /ubuntu/i ? "ubuntu" : "debian"
  end
end
