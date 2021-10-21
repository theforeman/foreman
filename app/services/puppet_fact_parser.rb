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
        if facts.dig(:os, :distro, :codename).presence || facts[:lsbdistcodename]
          os.release_name = facts.dig(:os, :distro, :codename).presence || facts[:lsbdistcodename]
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
      elsif facts.dig(:os, :distro, :description).presence || facts[:lsbdistdescription]
        family = os.deduce_family || 'Operatingsystem'
        os = os.becomes(family.constantize)
        os.description = os.shorten_description(facts.dig(:os, :distro, :description).presence || facts[:lsbdistdescription])
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
               facts[:hardwareisa]
             else
               facts[:architecture] || facts[:hardwareisa]
           end
    # ensure that we convert debian legacy to standard
    name = "x86_64" if name == "amd64"
    name = "aarch64" if name == "arm64"
    Architecture.where(:name => name).first_or_create if name.present?
  end

  def model
    name = facts[:productname] || facts[:model] || facts[:boardproductname]
    # if its a virtual machine and we didn't get a model name, try using that instead.
    name ||= facts[:virtual] if virtual
    Model.where(:name => name.strip).first_or_create if name.present?
  end

  def domain
    name = facts[:domain]
    Domain.unscoped.where(:name => name).first_or_create if name.present?
  end

  def ipmi_interface
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
    facter3_primary = facts.try(:fetch, "networking", nil).try(:fetch, "primary", nil)
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
    # system_uptime::seconds is Facter 3, we also fallback to Facter 2 uptime_seconds
    uptime_seconds = facts.fetch('system_uptime', {}).fetch('seconds', nil) || facts[:uptime_seconds]
    uptime_seconds.nil? ? nil : (Time.zone.now.to_i - uptime_seconds.to_i)
  end

  def virtual
    facts['is_virtual']
  end

  def ram
    if (value = facts.dig('memory', 'system', 'total_bytes'))
      value / 1.megabyte
    else
      facts['memorysize_mb']
    end
  end

  def sockets
    facts.dig('processors', 'physicalcount') || facts['physicalprocessorcount']
  end

  def cores
    facts.dig('processors', 'count') || facts['processorcount']
  end

  def disks_total
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
    os_name = facts.dig(:os, :name).presence || facts[:operatingsystem].presence || raise(::Foreman::Exception.new("invalid facts, missing operating system value"))
    # CentOS Stream doesn't have a minor version so it's good to check it at two places according to version of Facter that produced facts
    has_no_minor = facts[:lsbdistrelease]&.exclude?('.') || (facts.dig(:os, :name).presence && facts.dig(:os, :release, :minor).nil?)
    return 'CentOS_Stream' if os_name == 'CentOSStream' || (os_name == 'CentOS' && has_no_minor)

    if os_name == 'RedHat' && facts[:lsbdistid] == 'RedHatEnterpriseWorkstation'
      os_name += '_Workstation'
    end

    os_name
  end

  def os_release
    case os_name
    when /(suse|sles|gentoo)/i
      facts[:operatingsystemrelease]
    when /(windows)/i
      facts[:kernelrelease]
    when /AIX/i
      majoraix, tlaix, spaix, _yearaix = facts[:operatingsystemrelease].split("-")
      majoraix + "." + tlaix + spaix
    when /JUNOS/i
      majorjunos, minorjunos = facts[:operatingsystemrelease].split("R")
      majorjunos + "." + minorjunos
    when /FreeBSD/i
      facts[:operatingsystemrelease].gsub(/\-RELEASE\-p[0-9]+/, '')
    when /Solaris/i
      facts[:operatingsystemrelease].gsub(/_u/, '.')
    when /PSBM/i
      majorpsbm, minorpsbm = facts[:operatingsystemrelease].split(".")
      majorpsbm + "." + minorpsbm
    when /Archlinux/i
      # Archlinux is a rolling release, so it has no releases. 1.0 is always used
      '1.0'
    when /Debian/i
      return "99" if facts[:lsbdistcodename] =~ /sid/
      release = facts.dig(:os, :release, :full) || facts[:lsbdistrelease] || facts[:operatingsystemrelease]
      case release
      when 'bullseye/sid' # Debian Bullseye testing will be 11
        '11'
      else
        release
      end
    else
      facts.dig(:os, :release, :full) || facts[:lsbdistrelease] || facts[:operatingsystemrelease]
    end
  end
end
