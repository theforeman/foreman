class NXOS < Operatingsystem
  # We don't fetch any files here.
  PXEFILES = {}

  def template_kinds
    ["POAP"]
  end

  def available_loaders
    ["None"]
  end

  def pxedir(medium_provider = nil)
    "boot/$arch/images"
  end

  def url_for_boot(medium_provider, file)
    raise ::Foreman::Exception.new(N_("Function not available for %s"), display_family)
  end

  def boot_filename(host = nil)
    "poap.cfg/" + host.mac.delete(':').upcase
  end

  def kernel(_medium_provider)
    "none"
  end

  def initrd(_medium_provider)
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
    "#{major}#{('.' + minor.to_s) if minor.present?}#{('.' + release_name) if release_name.present?}"
  end

  def display_family
    "NX-OS"
  end
end
