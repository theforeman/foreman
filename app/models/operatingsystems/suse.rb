class Suse < Operatingsystem
  PXEFILES = {:kernel => "linux", :initrd => "initrd"}

  def pxe_type
    "yast"
  end

  def pxedir(medium_provider = nil)
    "boot/$arch/loader"
  end

  # suse installer receives the provisioning token on the kernel command line,
  # so the unattended endpoint can require it for these hosts.
  def token_enforced?
    true
  end

  def available_loaders
    self.class.all_loaders
  end

  def display_family
    "SUSE"
  end

  def shorten_description(description)
    return "" if description.blank?
    s = description.dup
    s.gsub!('SUSE Linux Enterprise Server', 'SLES')
    s.gsub!(/\(.+?\)/, '')
    s.squeeze! " "
    s.strip!
    s.presence || description
  end
end
