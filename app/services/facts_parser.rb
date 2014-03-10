module Facts
  class Parser
    attr_reader :facts

    def initialize facts
      @facts = HashWithIndifferentAccess.new(facts)
    end

    def operatingsystem
      orel    = case os_name
                  when /(suse|sles|gentoo)/i
                    facts[:operatingsystemrelease]
                  else
                    facts[:lsbdistrelease] || facts[:operatingsystemrelease]
                end

      if os_name == "Archlinux"
        # Archlinux is rolling release, so it has no release. We use 1.0 always
        args = { :name => os_name, :major => "1", :minor => "0" }
        os = Operatingsystem.where(args).first || Operatingsystem.new(args)
      elsif orel.present?
        if os_name == "Debian" and orel[/testing|unstable/i]
          case facts[:lsbdistcodename]
            when /wheezy/i
              orel = "7"
            when /jessie/i
              orel = "8"
            when /sid/i
              orel = "99"
          end
        elsif os_name[/AIX/i]
          majoraix, tlaix, spaix, yearaix = orel.split("-")
          os = majoraix[0,1] + "." + majoraix[1,1]
        elsif os_name[/JUNOS/i]
          majorjunos, minorjunos = orel.split("R")
          orel = majorjunos + "." + minorjunos
        end
        major, minor = orel.split(".")
        major.to_s.gsub!(/\D/,'') unless is_numeric? major
        minor.to_s.gsub!(/\D/,'') unless is_numeric? minor
        args = { :name => os_name, :major => major.to_s, :minor => minor.to_s }
        os = Operatingsystem.where(args).first || Operatingsystem.create!(args)
        os.release_name = facts[:lsbdistcodename] if facts[:lsbdistcodename] && (os_name[/debian|ubuntu/i] || os.family == 'Debian')
      else
        os = Operatingsystem.find_by_name(os_name) || Operatingsystem.create!(:name => os_name)
      end
      if facts[:lsbdistdescription] && os.description.blank?
        family = os.deduce_family || 'Operatingsystem'
        os.description = family.constantize.shorten_description facts[:lsbdistdescription]
      end
      os.save!
      os
    end

    def environment
      # by default, puppet doesn't store an env name in the database
      name = facts[:environment] || Setting[:default_puppet_environment]
      Environment.find_or_create_by_name name
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
      Architecture.find_or_create_by_name name unless name.blank?
    end

    def model
      name = facts[:productname] || facts[:model] || facts[:boardproductname]
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
      facts[:macaddress] == "00:00:00:00:00:00" ? nil : facts[:macaddress]
    end

    def ip
      facts[:ipaddress]
    end

    def certname
      facts[:clientcert]
    end

    private

    def os_name
      facts[:operatingsystem].blank? ? raise(::Foreman::Exception.new("invalid facts, missing operating system value")) : facts[:operatingsystem]
    end

    def is_numeric?(string)
      begin
        !!Integer(string)
      rescue ArgumentError, TypeError
        false
      end
    end

  end

end
