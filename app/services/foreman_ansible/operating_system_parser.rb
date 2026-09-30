# frozen_string_literal: true

module ForemanAnsible
  # Methods to parse facts related to the OS
  module OperatingSystemParser
    def operatingsystem
      args = { :name => os_name, :major => os_major, :minor => os_minor }
      args[:release_name] = os_release_name if os_name == 'Debian' || os_name == 'Ubuntu'
      # for Ansible, the CentOS Stream can be identified by missing minor version only
      args[:name] = "CentOS_Stream" if os_name == 'CentOS' && os_minor.blank?
      args[:description] = os_description

      Operatingsystem.find_or_create_by_attributes(args) do
        Operatingsystem.create!(args)
      end
    rescue ActiveRecord::RecordInvalid => e
      logger.debug do
        "Ansible facts parser: No OS could be created with " \
        "os_name='#{os_name}' os_major='#{os_major}' " \
        "os_minor='#{os_minor}': #{e.message}"
      end
      nil
    end

    def debian_os_major_sid
      release = if facts[:ansible_distribution_major_version] == 'n/a'
                  facts[:ansible_distribution_release]
                else
                  facts[:ansible_distribution_major_version]
                end
      case release
      when /bookworm/i
        '12'
      when /trixie/i
        '13'
      when /forky/i
        '14'
      end
    end

    def os_release_name
      return '' if os_name != 'Debian' && os_name != 'Ubuntu'
      facts[:ansible_distribution_release]
    end

    def os_major
      if os_name == 'Debian' &&
          (facts[:ansible_distribution_major_version][%r{/sid}i] ||
           facts[:ansible_distribution_major_version] == 'n/a')
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
      if os_name == 'Ubuntu'
        _, _, minor = os_release&.split('.', 3)
      else
        _, minor = os_release&.split('.', 2) ||
          (facts[:version].split('R') if os_name == 'junos')
      end
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
        windows_os_name.tr(" \n\t", '')
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
        windows_os_name
      else
        facts[:ansible_lsb] && facts[:ansible_lsb]['description']
      end
    end

    def windows_os_name
      (facts[:ansible_os_name] || facts[:ansible_distribution] || 'Microsoft Windows').strip
    end
  end
end
