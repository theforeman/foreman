class PuppetFactParser < FactParser
  attr_reader :facts

  def operatingsystem
    orel = os_release.dup

    if orel.present?
      major, minor = orel.split('.', 2)
      major = major.to_s.gsub(/\D/, '')
      minor = minor.to_s.gsub(/[^\d\.]/, '')
      args = {:name => os_name, :major => major, :minor => minor}
      os = Operatingsystem.find_or_initialize_by(args)
      if os_name[/debian|ubuntu/i] || os.family == 'Debian'
        if distro_codename
          os.release_name = distro_codename
        elsif os.release_name.blank?
          os.release_name = 'unknown'
        end
      end
    else
      os = Operatingsystem.find_or_initialize_by(:name => os_name)
    end

    if os.description.blank?
      if os_name == 'SLES'
        os.description = os_name + ' ' + orel.gsub('.', ' SP')
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
    # Facter 2.2 introduced the system_uptime fact
    uptime_seconds = facts.dig(:system_uptime, :seconds) || facts[:uptime_seconds]
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
    # Facter 2.2 introduced the processors.physicalcount fact
    facts.dig('processors', 'physicalcount') || facts['physicalprocessorcount']
  end

  def cores
    # Facter 2.2 introduced the processors.count fact
    facts.dig('processors', 'count') || facts['processorcount']
  end

  def disks_total
    # Facter 3.0 introduced the disks fact
    facts['disks']&.values&.sum { |disk| disk&.fetch('size_bytes', 0).to_i }
  end

  def kernel_version
    # Facter 3.0 introduced the os.kernel fact
    facts.dig(:os, :kernel, :release).presence || facts[:kernelrelease].presence
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
    # Facter 2.2 introduced the os fact
    os_name = facts.dig(:os, :name).presence || facts[:operatingsystem].presence || raise(::Foreman::Exception.new("invalid facts, missing operating system value"))
    # CentOS Stream doesn't have a minor version so it's good to check it at two places according to version of Facter that produced facts
    has_no_minor = facts[:lsbdistrelease]&.exclude?('.') || (facts.dig(:os, :name).presence && facts.dig(:os, :release, :minor).nil?)
    return 'CentOS_Stream' if os_name == 'CentOSStream' || (os_name == 'CentOS' && has_no_minor)

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

  def os_release
    case os_name
    when /(windows)/i
      facts[:kernelrelease]
    when /AIX/i
      majoraix, tlaix, spaix, _yearaix = os_release_full.split("-")
      majoraix + "." + tlaix + spaix
    when /JUNOS/i
      majorjunos, minorjunos = os_release_full.split("R")
      majorjunos + "." + minorjunos
    when /FreeBSD/i
      os_release_full.gsub(/\-RELEASE\-p[0-9]+/, '')
    when /Solaris/i
      os_release_full.gsub(/_u/, '.')
    when /PSBM/i
      majorpsbm, minorpsbm = os_release_full.split(".")
      majorpsbm + "." + minorpsbm
    when /Archlinux/i
      # Archlinux is a rolling release, so it has no releases. 1.0 is always used
      '1.0'
    when /Debian/i
      return "99" if distro_codename =~ /sid/
      release = os_release_full
      case release
      when 'bullseye/sid' # Debian Bullseye testing will be 11
        '11'
      else
        release
      end
    else
      os_release_full
    end
  end

  # The full OS release (7 / 7.9 / 7.6.1810 / 2012 R2 / 20.04)
  def os_release_full
    # Facter 2.2 introduced the os.release fact
    facts.dig(:os, :release, :full) || facts[:operatingsystemrelease]
  rescue StandardError => e
    logger.error { "Failed to read the full OS release: #{e}" }
    nil
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
