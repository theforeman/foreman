class Suse < Operatingsystem
  PXEFILES = {:kernel => "linux", :initrd => "initrd"}

  # Simple output of the media url
  def mediumpath(host)
    medium_uri(host).to_s
  end

  def pxe_type
    "yast"
  end

  def pxedir
    "boot/$arch/loader"
  end

  def available_loaders
    self.class.all_loaders
  end

  def url_for_boot(file)
    pxedir + "/" + PXEFILES[file]
  end

  def display_family
    "SUSE"
  end

  def self.shorten_description(description)
    return "" if description.blank?
    s = description.dup
    s.gsub!('SUSE Linux Enterprise Server', 'SLES')
    s.gsub!(/\(.+?\)/, '')
    s.squeeze! " "
    s.strip!
    s.presence || description
  end
end
