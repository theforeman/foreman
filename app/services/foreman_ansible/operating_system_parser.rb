# frozen_string_literal: true

module ForemanAnsible
  # Methods to parse facts related to the OS
  module OperatingSystemParser
    def operatingsystem
      args = { :name => os_name, :major => os_major, :minor => os_minor }
      args[:release_name] = os_release_name if os_name == 'Debian' || os_name == 'Ubuntu'
      return @local_os if local_os(args).present?
      return @new_os if new_os(args).present?
      logger.debug do
        'Ansible facts parser: No OS could be created with '\
        "os_name='#{os_name}' os_major='#{os_major}' "\
        "os_minor='#{os_minor}': "\
        "#{@new_os.errors if @new_os.present?}"
      end
      nil
    end

    def local_os(args)
      @local_os = Operatingsystem.where(args).first
    end

    def new_os(args)
      return @new_os if @new_os.present?
      @new_os = Operatingsystem.new(args.merge(:description => os_description))
      @new_os if @new_os.valid? && @new_os.save
    end

    def debian_os_major_sid
      case facts[:ansible_distribution_major_version]
      when /wheezy/i
        '7'
      when /jessie/i
        '8'
      when /stretch/i
        '9'
      when /buster/i
        '10'
      end
    end

    def os_release_name
      return '' if os_name != 'Debian' && os_name != 'Ubuntu'
      facts[:ansible_distribution_release]
    end

    def os_major
      if os_name == 'Debian' &&
          facts[:ansible_distribution_major_version][%r{\/sid}i]
        debian_os_major_sid
      else
        facts[:ansible_distribution_major_version] ||
            facts[:ansible_lsb] && facts[:ansible_lsb]['major_release'] ||
            (facts[:version].split('R')[0] if os_name == 'junos')
      end
    end

    def os_release
      facts[:ansible_distribution_version] ||
          facts[:ansible_lsb] && facts[:ansible_lsb]['release']
    end

    def os_minor
      _, minor = os_release&.split('.', 2) ||
          (facts[:version].split('R') if os_name == 'junos')
      # Until Foreman supports os.minor as something that's not a number,
      # we should remove the extra dots in the version. E.g:
      # '6.1.7601.65536' becomes '6.1.760165536'
      if facts[:ansible_os_family] == 'Windows'
        minor, patch = minor.split('.', 2)
        patch.tr!('.', '')
        minor = "#{minor}.#{patch}"
      end
      minor || ''
    end

    def os_name
      if facts[:ansible_os_family] == 'Windows'
        facts[:ansible_os_name].tr(" \n\t", '') ||
            facts[:ansible_distribution].tr(" \n\t", '')
      else
        # RHEL 7 is marked as either RedHatEnterpriseServer or RedHatEnterpriseWorkstation, RHEL 8 is lsb id is RedHatEnterprise
        # but we always consider it just RHEL on this level, workstation is differentiated below
        distribution = facts[:ansible_lsb].try(:[], 'id') || facts[:ansible_distribution]

        case distribution
        when 'RedHatEnterprise', 'RedHatEnterpriseServer'
          distribution = 'RedHat'
        when 'RedHatEnterpriseWorkstation'
          distribution = 'RedHat_Workstation'
        end

        distribution
      end
    end

    def os_description
      if facts[:ansible_os_family] == 'Windows'
        facts[:ansible_os_name].strip || facts[:ansible_distribution].strip
      else
        facts[:ansible_lsb] && facts[:ansible_lsb]['description']
      end
    end
  end
end
