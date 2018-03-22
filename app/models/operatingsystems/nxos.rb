class NXOS < Operatingsystem
  # We don't fetch any files here.
  PXEFILES = {}

  # Simple output of the media url
  def mediumpath(host)
    medium_uri(host).to_s
  end

  def template_kinds
    ["POAP"]
  end

  def available_loaders
    ["None"]
  end

  def pxedir
    "boot/$arch/images"
  end

  def url_for_boot(file)
    raise ::Foreman::Exception.new(N_("Function not available for %s"), self.display_family)
  end

  def boot_filename(host = nil)
    "poap.cfg/"+host.mac.delete(':').upcase
  end

  def kernel(arch)
    "none"
  end

  def initrd(arch)
    "none"
  end

  # release_name can be used to complete Cisco release numbers.
  def use_release_name?
    true
  end

  # release_name can have upper case letters and we want to keep it that way
  def downcase_release_name
    release_name
  end

  # generate a Cisco release number using release_name as an auxiliary field
  def release
    "#{major}#{('.' + minor.to_s) unless minor.blank?}#{('.' + release_name) unless release_name.blank?}"
  end

  def display_family
    "NX-OS"
  end
end
