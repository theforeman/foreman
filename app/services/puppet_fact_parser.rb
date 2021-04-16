# The PuppetFactParser is really a FacterFactParser. Currently it is compatible
# with Facter 2.2 or newer
class PuppetFactParser < FactParser
  attr_reader :facts

  def operatingsystem
    major, minor = os_release_major_minor

    if major.presence
      args = {:name => os_name, :major => major, :minor => minor}
      os = Operatingsystem.find_or_initialize_by(args)
      if distro_codename
        os.release_name = distro_codename
      elsif os.release_name.blank? && os_name[/debian|ubuntu/i] || os.family == 'Debian'
        os.release_name = 'unknown'
      end
    else
      os = Operatingsystem.find_or_initialize_by(:name => os_name)
    end

    if os.description.blank?
      if os_name == 'SLES'
        os.description = "#{os_name} #{major} SP#{minor}" if major && minor
      elsif distro_description
        family = os.deduce_family || 'Operatingsystem'
        os = os.becomes(family.constantize)
        os.description = os.shorten_description(distro_description)
      end
    end

    if os.new_record?
      os.save!
      Operatingsystem.find_by_id(os.id) # complete reload to be an instance of the STI subclass
    else
      os.save!
      os
    end
  end

  def environment
    return unless Foreman::Plugin.find(:foreman_puppet)
    # by default, puppet doesn't store an env name in the database
    name = facts[:environment] || facts[:agent_specified_environment] || Setting[:default_puppet_environment]
    ForemanPuppet::Environment.unscoped.where(:name => name).first_or_create
  end

  def architecture
    # On solaris and junos architecture fact is hardwareisa
    name = case os_name
             when /(sunos|solaris|junos)/i
               hardware_isa
             else
               architecture_fact || hardware_isa
           end
    # Normalize some output, like on Debian and FreeBSD
    name = "x86_64" if name == "amd64"
    name = "aarch64" if name == "arm64"
    Architecture.where(:name => name).first_or_create if name.present?
  end

  def model
    # TODO: not sure where model comes from, not Facter
    name = dmi_product_name || facts[:model] || dmi_board_product
    # if its a virtual machine and we didn't get a model name, try using that instead.
    name ||= facts[:virtual] if virtual
    Model.where(:name => name.strip).first_or_create if name.present?
  end

  def domain
    # Facter 3.0 introduced the networking fact
    name = facts.dig(:networking, :domain).presence || facts[:domain].presence
    Domain.unscoped.where(:name => name).first_or_create if name.present?
  end

  def ipmi_interface
    # ipmi_ facts are custom facts in foreman-discovery-image
    ipmi = facts.select { |name, _| name =~ /\Aipmi_(.*)\Z/ }.map { |name, value| [name.sub(/\Aipmi_/, ''), value] }
    Hash[ipmi].with_indifferent_access
  end

  def interfaces
    interfaces = super
    return interfaces unless use_legacy_facts?
    underscore_device_regexp = /\A([^_]*)_(\d+)\z/
    interfaces.clone.each do |identifier, _|
      matches = identifier.match(underscore_device_regexp)
      next unless matches
      new_name = "#{matches[1]}.#{matches[2]}"
      interfaces[new_name] = interfaces.delete(identifier)
    end
    interfaces
  end

  def interfaces_attribute_map(attribute)
    map = {
      'mac' => 'macaddress',
      'ip' => 'ipaddress',
      'ip6' => 'ipaddress6',
    }
    map.has_key?(attribute) ? map[attribute] : attribute
  end

  def suggested_primary_interface(host)
    # facter 3.x: find 'primary' fact in 'networking' structure
    facter3_primary = facts.dig(:networking, :primary).presence
    return [facter3_primary, interfaces[facter3_primary]] if facter3_primary
    super
  end

  def certname
    facts[:clientcert]
  end

  def support_interfaces_parsing?
    true
  end

  def boot_timestamp
    uptime_seconds = facts.dig(:system_uptime, :seconds)
    uptime_seconds.nil? ? nil : (Time.zone.now.to_i - uptime_seconds.to_i)
  end

  def virtual
    facts['is_virtual']
  end

  def ram
    # Facter 3.0 introduced the memory fact
    if (value = facts.dig('memory', 'system', 'total_bytes'))
      value / 1.megabyte
    else
      facts['memorysize_mb']
    end
  end

  def sockets
    facts.dig('processors', 'physicalcount')
  end

  def cores
    facts.dig('processors', 'count')
  end

  def disks_total
    # Facter 3.0 introduced the disks fact
    facts['disks']&.values&.sum { |disk| disk&.fetch('size_bytes', 0).to_i }
  end

  private

  # remove when dropping support for facter < 3.0
  def get_interfaces_legacy
    if facts[:interfaces]&.present?
      facts[:interfaces].downcase.split(',')
    else
      []
    end
  end

  def get_interfaces
    return get_interfaces_legacy if use_legacy_facts?
    facts.dig(:networking, :interfaces)&.keys || []
  end

  # remove when dropping support for facter < 3.0
  def get_facts_for_interface_legacy(interface)
    iface_facts = @facts.each_with_object([]) do |(name, value), facts|
      facts << [name.chomp("_#{interface}"), value] if name.end_with?("_#{interface}")
    end
    iface_facts = HashWithIndifferentAccess[iface_facts]
    logger.debug { "Interface #{interface} facts: #{iface_facts.inspect}" }
    iface_facts
  end

  def get_facts_for_interface(interface)
    return get_facts_for_interface_legacy(interface) if use_legacy_facts?
    interface_fact = facts.dig(:networking, :interfaces, interface) || {}
    iface_facts = interface_fact.each_with_object([]) do |(name, value), facts|
      facts << [interfaces_attribute_map(name), value] if interfaces_attribute_map(name)
    end
    iface_facts = HashWithIndifferentAccess[iface_facts]
    logger.debug { "Interface #{interface} facts: #{iface_facts.inspect}" }
    iface_facts
  end

  def facterversion
    @facterversion ||= facts[:facterversion]&.split('.')&.map(&:to_i) || []
  end

  def use_legacy_facts?
    facterversion[0].nil? || facterversion[0] < 3
  end

  def os_name
    os_name = facts.dig(:os, :name).presence || raise(::Foreman::Exception.new("invalid facts, missing operating system value"))

    if os_name == 'RedHat' && distro_id == 'RedHatEnterpriseWorkstation'
      os_name += '_Workstation'
    elsif os_name == 'windows' && facts.dig(:os, :windows, :installation_type) == 'Client'
      os_name += '_client'
    end

    os_name
  rescue ::Foreman::Exception
    raise
  rescue StandardError => e
    logger.error { "Failed to read the OS name: #{e}" }
    raise(::Foreman::Exception.new("invalid facts, missing operating system value"))
  end

  def os_release_major_minor
    case os_name
    when /windows/i
      # Windows major releases can contain letters so we use the kernel release
      facts[:kernelrelease].split('.')[0, 2]
    when /FreeBSD/i
      # Facter 2.2 - 2.5 reported 0 as minor while 3+ reports 0-RELEASE-p6
      minor = facts.dig(:os, :release, :minor)&.gsub(/\-RELEASE\-p[0-9]+/, '')
      [facts.dig(:os, :release, :major), minor]
    when /Archlinux/i
      # Archlinux is a rolling release, so it has no releases. 1.0 is always used
      ['1', '0']
    when /Debian/i
      case os_release_full
      when 'bullseye/sid' # Debian Bullseye testing will be 11
        ['11', nil]
      else
        [facts.dig(:os, :release, :major), facts.dig(:os, :release, :minor)]
      end
    when /Ubuntu/i
      # Facter never reports a minor and reports 20.04 as the major
      # Foreman has historically seen 20 as the major and 04 as the minor
      os_release_full.split('.')[0, 2]
    else
      [facts.dig(:os, :release, :major), facts.dig(:os, :release, :minor)]
    end
  end

  # The full OS release (7 / 7.9 / 7.6.1810 / 2012 R2 / 20.04)
  def os_release_full
    facts.dig(:os, :release, :full)
  end

  # This fact returns the distribution's id, which typically relies on
  # lsb-release to be installed. As such, it's an optional fact
  def distro_id
    # Facter 3.0 introduced the os.distro fact
    facts.dig(:os, :distro, :id).presence || facts[:lsbdistid].presence
  rescue StandardError => e
    logger.warning { "Failed to the read distribution id: #{e}" }
    nil
  end

  # This fact returns the distribution's codename, which typically relies on
  # lsb-release to be installed. As such, it's an optional fact
  def distro_codename
    # Facter 3.0 introduced the os.distro fact
    facts.dig(:os, :distro, :codename).presence || facts[:lsbdistcodename].presence
  rescue StandardError => e
    logger.warning { "Failed to read the distribution codename: #{e}" }
    nil
  end

  # This fact returns the distribution's description, which typically relies on
  # lsb-release to be installed. As such, it's an optional fact
  def distro_description
    # Facter 3.0 introduced the os.distro fact
    facts.dig(:os, :distro, :description).presence || facts[:lsbdistdescription].presence
  rescue StandardError => e
    logger.warning { "Failed to read the distribution description: #{e}" }
    nil
  end

  # Product name from DMI
  def dmi_product_name
    # Facter 3.0 introduced the dmi fact
    facts.dig(:dmi, :product, :name).presence || facts[:productname]
  rescue StandardError => e
    logger.warning { "Failed to read the product name: #{e}" }
    nil
  end

  # Board product name as the DMI board reports it.
  def dmi_board_product
    # Facter 3.0 introduced the dmi fact
    facts.dig(:dmi, :board, :product).presence || facts[:boardproductname]
  rescue StandardError => e
    logger.warning { "Failed to read the board product: #{e}" }
    nil
  end

  # Architecture (x86_64 / amd64 /x64 / i386 / x64).
  def architecture_fact
    # Facter 3.0 introduced the os.architecture fact
    facts.dig(:os, :architecture).presence || facts[:architecture].presence
  rescue StandardError => e
    logger.error { "Failed to read the architecture: #{e}" }
    nil
  end

  # Hardware ISA (x86_64 / i686 / i386).
  def hardware_isa
    # Facter 3.0 introduced the processors.isa fact
    facts.dig(:processors, :isa).presence || facts[:hardwareisa].presence
  rescue StandardError => e
    logger.error { "Failed to read the hardware ISA: #{e}" }
    nil
  end
end
