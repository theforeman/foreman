module Facts
  class Importer
    attr_reader :facts

    def initialize facts
      @facts = HashWithIndifferentAccess.new(facts)
    end

    def operatingsystem
      os_name = facts[:operatingsystem]
      orel    = case os_name
                  when /(suse|sles)/i
                    facts[:operatingsystemrelease]
                  else
                    facts[:lsbdistrelease] || facts[:operatingsystemrelease]
                end

      if os_name == "Archlinux"
        # Archlinux is rolling release, so it has no release. We use 1.0 always
        Operatingsystem.find_or_create_by_name_and_major_and_minor os_name, "1", "0"
      elsif orel.present?
        major, minor = orel.split(".")
        minor        ||= ""
        Operatingsystem.find_or_create_by_name_and_major_and_minor os_name, major, minor
      else
        Operatingsystem.find_or_create_by_name os_name
      end
    end

    def environment
      # by default, puppet doesn't store an env name in the database
      name = facts[:environment] || Setting[:default_puppet_environment]
      Environment.find_or_create_by_name name
    end

    def architecture
      # On solaris architecture fact is harwareisa
      name = facts[:architecture] || facts[:hardwareisa]
      # ensure that we convert debian legacy to standard
      name = "x86_64" if name == "amd64"
      Architecture.find_or_create_by_name name unless name.blank?
    end

    def model
      name = facts[:productname] || facts[:model]
      # if its a virtual machine and we didn't get a model name, try using that instead.
      name ||= facts[:is_virtual] == "true" ? facts[:virtual] : nil
      Model.find_or_create_by_name(name.strip) unless name.blank?
    end

    def domain
      name = facts[:domain]
      Domain.find_or_create_by_name name unless name.blank?
    end

    def primary_interface
      mac    = facts[:macaddress]
      ip     = facts[:ipaddress]
      interfaces.each do |int, values|
        return int.to_s if (values[:mac] == mac and values[:ip] == ip)
      end
      nil
    end

    EXCLUDED_INTERFACES = %w[lo usb0] unless defined?(EXCLUDED_INTERFACES)

    def interfaces
      ifs = facts[:interfaces]
      return {} if ifs.empty? or (ifs=ifs.split(",")).empty?
      interfaces = HashWithIndifferentAccess.new

      (ifs - EXCLUDED_INTERFACES).each do |int|
        if (ip = facts["ipaddress_#{int}".to_sym]) and (mac = facts["macaddress_#{int}".to_sym])
          interfaces[int] = { :ip => ip, :mac => mac }
        end
      end
      interfaces
    end

    # TODO: Remove these method once interfaces management is enabled
    def mac
      facts[:macaddress]
    end

    def ip
      facts[:ipaddress]
    end

    def certname
      facts[:clientcert]
    end
  end

end
