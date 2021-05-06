module ForemanSalt
  class FactParser < ::FactParser
    attr_reader :facts

    def operatingsystem
      os = Operatingsystem.where(os_hash).first_or_initialize
      if os.new_record?
        os.deduce_family
        os.release_name = facts[:lsb_distrib_codename]
        os.save
      end
      os if os.persisted?
    end

    def architecture
      name = facts[:osarch]
      name = 'x86_64' if name == 'amd64'
      Architecture.where(:name => name).first_or_create if name.present?
    end

    def environment
      # Don't touch the Puppet environment field
    end

    def model
      name = facts[:productname]
      Model.where(:name => name.strip).first_or_create if name.present?
    end

    def domain
      name = facts[:domain]
      Domain.where(:name => name).first_or_create if name.present?
    end

    def ip
      ip = facts.find { |fact, value| fact =~ /^fqdn_ip4/ && value && value != '127.0.0.1' }
      ip[1] if ip
    end

    def primary_interface
      interface = interfaces.find { |_, value| value[:ipaddress] == ip }
      interface[0] if interface
    end

    def mac
      interface = interfaces.find { |_, value| value[:ipaddress] == ip }
      interface[1][:macaddress] if interface
    end

    def ipmi_interface
      nil
    end

    def interfaces
      interfaces = {}

      facts.each do |fact, value|
        next unless value && fact.to_s =~ /^ip_interfaces/

        (_, interface_name) = fact.split(FactName::SEPARATOR)

        next if (IPAddr.new('fe80::/10').include?(value) rescue false)

        if interface_name.present? && interface_name != 'lo'
          interface = interfaces.fetch(interface_name, {})
          interface[:macaddress] = macs[interface_name]
          if Net::Validations.validate_ip6(value)
            interface[:ipaddress6] = value unless interface.include?(:ipaddress6)
          else
            interface[:ipaddress] = value unless interface.include?(:ipaddress)
          end
          interfaces[interface_name] = interface
        end
      end

      interfaces.each do |name, interface|
        set_additional_attributes(interface, name)
      end

      interfaces
    end

    def support_interfaces_parsing?
      true
    end

    private

    def os_hash
      name = facts[:os]
      (_, major, minor, sub) = /(\d+)\.?(\d+)?\.?(\d+)?/.match(facts[:osrelease]).to_a
      minor = "" if minor.nil?
      if name == 'CentOS'
        if sub
          minor += '.' + sub
        end
      end
      { :name => name, :major => major, :minor => minor }
    end

    def macs
      unless @macs
        @macs = {}
        facts.each do |fact, value|
          next unless value && fact.to_s =~ /^hwaddr_interfaces/

          data = fact.split(FactName::SEPARATOR)
          interface = data[1]
          macs[interface] = value
        end
      end
      @macs
    end
  end
end
