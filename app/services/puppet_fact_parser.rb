class PuppetFactParser < FactParser
  attr_reader :facts

  def operatingsystem
    orel = os_release.dup

    if os_name == "Archlinux"
      # Archlinux is rolling release, so it has no release. We use 1.0 always
      args = {:name => os_name, :major => "1", :minor => "0"}
      os = Operatingsystem.find_or_initialize_by(args)
    elsif orel.present?
      if os_name == "Debian" && orel[/testing|unstable/i]
        case facts[:lsbdistcodename]
          when /wheezy/i
            orel = "7"
          when /jessie/i
            orel = "8"
          when /sid/i
            orel = "99"
        end
      elsif os_name[/AIX/i]
        majoraix, tlaix, spaix, _yearaix = orel.split("-")
        orel = majoraix + "." + tlaix + spaix
      elsif os_name[/JUNOS/i]
        majorjunos, minorjunos = orel.split("R")
        orel = majorjunos + "." + minorjunos
      elsif os_name[/FreeBSD/i]
        orel.gsub!(/\-RELEASE\-p[0-9]+/, '')
      elsif os_name[/Solaris/i]
        orel.gsub!(/_u/, '.')
      end
      major, minor = orel.split('.', 2)
      major = major.to_s.gsub(/\D/, '')
      minor = minor.to_s.gsub(/[^\d\.]/, '')
      args = {:name => os_name, :major => major, :minor => minor}
      os = Operatingsystem.find_or_initialize_by(args)
      os.release_name = facts[:lsbdistcodename] if facts[:lsbdistcodename] && (os_name[/debian|ubuntu/i] || os.family == 'Debian')
    else
      os = Operatingsystem.find_or_initialize_by(:name => os_name)
    end
    if os.description.blank?
      if os_name == 'SLES'
        os.description = os_name + ' ' + orel.gsub('.', ' SP')
      elsif facts[:lsbdistdescription]
        family = os.deduce_family || 'Operatingsystem'
        os.description = family.constantize.shorten_description facts[:lsbdistdescription]
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
    # by default, puppet doesn't store an env name in the database
    name = facts[:environment] || Setting[:default_puppet_environment]
    Environment.where(:name => name).first_or_create
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
    Architecture.where(:name => name).first_or_create unless name.blank?
  end

  def model
    name = facts[:productname] || facts[:model] || facts[:boardproductname]
    # if its a virtual machine and we didn't get a model name, try using that instead.
    name ||= facts[:is_virtual] == "true" ? facts[:virtual] : nil
    Model.where(:name => name.strip).first_or_create unless name.blank?
  end

  def domain
    name = facts[:domain]
    Domain.where(:name => name).first_or_create unless name.blank?
  end

  def ipmi_interface
    ipmi = facts.select { |name, _| name =~ /\Aipmi_(.*)\Z/ }.map { |name, value| [name.sub(/\Aipmi_/, ''), value] }
    Hash[ipmi].with_indifferent_access
  end

  # since Puppet converts eth0.0 and eth0:0 to eth0_0 we assume it's vlan interface
  # we can't do much better until we have more information from facter
  def interfaces
    interfaces = super

    underscore_device_regexp = /\A([^_]*)_(\d+)\z/
    interfaces.clone.each do |identifier, _|
      matches = identifier.match(underscore_device_regexp)
      next unless matches
      new_name = "#{matches[1]}.#{matches[2]}"
      interfaces[new_name] = interfaces.delete(identifier)
    end

    interfaces
  end

  def certname
    facts[:clientcert]
  end

  def support_interfaces_parsing?
    true
  end

  private

  def get_interfaces
    if facts[:interfaces] && !facts[:interfaces].blank?
      facts[:interfaces].split(',')
    else
      []
    end
  end

  def get_facts_for_interface(interface)
    iface_facts = @facts.inject([]) do |facts, (name, value)|
      facts << [name.chomp("_#{interface}"), value] if name.end_with?("_#{interface}")
      facts
    end
    iface_facts = HashWithIndifferentAccess[iface_facts]
    logger.debug { "Interface #{interface} facts: #{iface_facts.inspect}" }
    iface_facts
  end

  def os_name
    facts[:operatingsystem].blank? ? raise(::Foreman::Exception.new("invalid facts, missing operating system value")) : facts[:operatingsystem]
  end

  def os_release
    case os_name
    when /(suse|sles|gentoo)/i
      facts[:operatingsystemrelease]
    when /(windows)/i
      facts[:kernelrelease]
    else
      facts[:lsbdistrelease] || facts[:operatingsystemrelease]
    end
  end
end
