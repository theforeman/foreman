module ForemanChef
  class FactParser < ::FactParser
    VIRTUAL = /\A([a-z0-9]+)[:.](\d+)\Z/
    VIRTUAL_NAMES = /#{VIRTUAL}|#{BRIDGES}|#{BONDS}/

    def operatingsystem
      os_name = facts['lsb::id'] || facts['platform']
      release = facts['lsb::release'] || facts['platform_version']
      # if we have no release information we can't assign OS properly (e.g. missing redhat-lsb)
      if release.nil?
        major, minor = 1, nil
      else
        major, minor = release.split('.')
      end

      if facts['platform'] == 'windows'
        release_name = facts['kernel::name']
        os_name = os_name.capitalize
      else
        # to keep OS names consistent with other cfgmgt agents we skip description importing
        # description = facts['lsb::description']
        release_name = facts['lsb::codename']
      end

      # convert OHAI names to Foreman common OS names
      case os_name
        when 'RedHatEnterpriseServer'
          os_name = 'RedHat'
      end

      # So far only CentOS needs exception
      case os_name
        when 'CentOS'
          if major.to_i >= 7
            # get the minor.build number, e.g. 7.2.1511 -> 2.1511
            minor = release[2..-1]
          end
        when 'centos'
          # Centos Stream doesn't have minor version on need to replace blank spaces due to name restriction
          os_name = facts.dig(:os_release, :name).tr(' ', '_') unless minor
      end

      begin
        klass = os_name.constantize
      rescue NameError => _
        logger.debug "unknown operating system #{os_name}, fallback to generic type"
        klass = Operatingsystem
      end

      args = { :name => os_name, :major => major.to_s, :minor => minor.to_s }
      klass.where(args).first || klass.new(args.merge(:release_name => release_name)).tap(&:save!)
    end

    # we don't want to parse puppet environment, foreman_chef already has its own environment
    def environment
      nil
    end

    def architecture
      name = facts['kernel::machine']
      name = "x86_64" if name == "amd64"
      Architecture.where(:name => name).first_or_create if name.present?
    end

    def model
      if facts['virtualization'].present?
        name = facts['virtualization']['system']
      else
        name = facts['dmi::system::product_name']
      end
      Model.where(:name => name.strip).first_or_create if name.present?
    end

    def domain
      name = facts['domain']
      Domain.where(:name => name).first_or_create if name.present?
    end

    def ipmi_interface
      if facts['ipmi::mac_address'].present?
        { 'ipaddress' => facts['ipmi::address'], 'macaddress' => facts['ipmi::mac_address'] }.with_indifferent_access
      end
    end

    def certname
      facts['chef_node_name']
    end

    def support_interfaces_parsing?
      true
    end

    def parse_interfaces?
      support_interfaces_parsing? && !Setting['ignore_puppet_facts_for_provisioning']
    end

    def boot_timestamp
      Time.zone.now.to_i - facts['system_uptime::seconds'].to_i
    end

    private

    def logger
      Foreman::Logging.logger('background')
    end

    # meant to be implemented in inheriting classes
    # should return hash with indifferent access in following format:
    # { 'link': 'true',
    #   'macaddress': '00:00:00:00:00:FF',
    #   'ipaddress': nil,
    #   'any_other_fact': 'value' }
    #
    # note that link and macaddress are mandatory
    def get_facts_for_interface(interface)
      facts = interfaces_hash[interface]
      hash = {
        'link' => facts['state'] == 'up',
        'macaddress' => get_address_by_family(facts['addresses'], 'lladdr'),
        'ipaddress' => get_address_by_family(facts['addresses'], 'inet'),
      }
      hash['tag'] = facts['vlan']['id'] if facts['vlan'].present?
      hash.with_indifferent_access
    end

    # meant to be implemented in inheriting classes
    # should return array of interfaces names, e.g.
    #   ['eth0', 'eth0.0', 'eth1']
    def get_interfaces
      interfaces_hash.keys
    end

    def get_address_by_family(addresses, family)
      addresses.detect { |address, attributes| attributes['family'] == family }.try(:first)
    end

    def network_hash
      @network_hash ||= ForemanChef::FactImporter::Sparser.new.unsparse(facts.select { |k, v| k.start_with?('network::interfaces::') }).try(:[], 'network') || {}
    end

    def interfaces_hash
      @interfaces_hash ||= network_hash.try(:[], 'interfaces') || {}
    end

    # adds attributes like virtual
    def set_additional_attributes(attributes, name)
      if name =~ VIRTUAL_NAMES
        attributes[:virtual] = true
        if Regexp.last_match(1).nil? && name =~ BRIDGES
          attributes[:bridge] = true
        else
          attributes[:attached_to] = Regexp.last_match(1)
        end
      else
        attributes[:virtual] = false
      end
      attributes
    end
  end
end
