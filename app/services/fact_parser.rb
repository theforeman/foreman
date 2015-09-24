class FactParser
  delegate :logger, :to => :Rails
  VIRTUAL = /\A([a-z0-9]+)_(\d+)\Z/
  BRIDGES = /\A(vir)?br\d+(_nic)?\Z/
  BONDS = /\A(bond\d+)\Z|\A(lagg\d+)\Z/
  VIRTUAL_NAMES = /#{VIRTUAL}|#{BRIDGES}|#{BONDS}/

  def self.parser_for(type)
    parsers[type.to_s] || parsers[:puppet]
  end

  def self.parsers
    @parsers ||= { :puppet => PuppetFactParser }.with_indifferent_access
  end

  def self.register_fact_importer(key, klass)
    Foreman::Deprecation.deprecation_warning("1.11", "Use factParser.register_fact_parser instead")
    register_fact_parser(key, klass)
  end

  def self.register_fact_parser(key, klass)
    parsers[key.to_sym] = klass
  end

  attr_reader :facts

  # facts are hash of fresh data coming from fact upload in following format
  #   { fqdn: value, hostname: value }
  def initialize(facts)
    @facts = HashWithIndifferentAccess.new(facts)
  end

  def operatingsystem
    raise NotImplementedError, not_implemented_error(__method__)
  end

  def environment
    raise NotImplementedError, not_implemented_error(__method__)
  end

  def architecture
    raise NotImplementedError, not_implemented_error(__method__)
  end

  def model
    raise NotImplementedError, not_implemented_error(__method__)
  end

  def domain
    raise NotImplementedError, not_implemented_error(__method__)
  end

  def ipmi_interface
    raise NotImplementedError, not_implemented_error(__method__)
  end

  # should return hash with indifferent access in following format:
  #   {
  #      'eth0': {'link': 'true', 'macaddress': '00:00:00:00:00:FF', 'ipaddress': nil, 'any_other_fact': 'value'},
  #      'eth0.0': { ... }
  #   }
  def interfaces
    @interfaces ||= begin
      result = {}

      interfaces = remove_ignored(normalize_interfaces(get_interfaces))
      logger.debug "We have following interfaces '#{interfaces.join(', ')}' based on facts"

      interfaces.each do |interface|
        iface_facts = get_facts_for_interface(interface)
        iface_facts = set_additional_attributes(iface_facts, interface)
        result[interface] = iface_facts
      end
      result.with_indifferent_access
    end
  end

  # tries to detect primary interface among interfaces using host name
  def suggested_primary_interface(host)
    # we search among interface with ip and mac if we didn't find it by name
    potential = interfaces.select { |_, values| values[:ipaddress].present? && values[:macaddress].present? }
    find_interface_by_name(host.name) || find_physical_interface(potential) ||
      find_virtual_interface(potential) || potential.first || interfaces.first
  end

  def certname
    raise NotImplementedError, not_implemented_error(__method__)
  end

  def support_interfaces_parsing?
    false
  end

  def parse_interfaces?
    support_interfaces_parsing? && !Setting['ignore_facts_for_provisioning']
  end

  private

  def find_interface_by_name(host_name)
    interfaces.detect do |int, values|
      if (ip = values[:ipaddress]).present?
        begin
          if Resolv::DNS.new.getnames(ip).any? { |name| name.to_s == host_name }
            logger.debug "resolved #{host_name} for #{ip}, #{int} is selected as primary"
            return [int, values]
          end
        rescue Resolv::ResolvError => e
          logger.debug "could not resolv name for #{ip} because of #{e} #{e.message}"
          nil
        end
      end
    end
  end

  def find_physical_interface(interfaces)
    interfaces.detect { |int, _| int.to_s !~ FactParser::VIRTUAL_NAMES }
  end

  def find_virtual_interface(interfaces)
    interfaces.detect { |int, _| int.to_s =~ /#{FactParser::BONDS}/ }
  end

  # adds attributes like virtual
  def set_additional_attributes(attributes, name)
    if name =~ VIRTUAL_NAMES
      attributes[:virtual] = true
      if $1.nil? && name =~ BRIDGES
        attributes[:bridge] = true
      else
        attributes[:attached_to] = $1

        if @facts[:vlans].present?
          vlans = @facts[:vlans].split(',')
          tag = name.split('_').last
          attributes[:tag] = vlans.include?(tag) ? tag : ''
        end
      end
    else
      attributes[:virtual] = false
    end
    attributes
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
    raise NotImplementedError, "parsing interface facts is not supported in #{self.class}"
  end

  # meant to be implemented in inheriting classes
  # should return array of interfaces names, e.g.
  #   ['eth0', 'eth0.0', 'eth1']
  def get_interfaces
    raise NotImplementedError, "parsing interfaces is not supported in #{self.class}"
  end

  # these interfaces are ignored when parsing interface facts
  def ignored_interfaces
    /\A(lo(?!cal_area_connection)|usb|vnet)/
  end

  def remove_ignored(interfaces)
    interfaces.clone.delete_if { |i| i.match(ignored_interfaces) }
  end

  def normalize_interfaces(interfaces)
    interfaces.map(&:downcase)
  end

# creating if iface_facts[:link] == 'true' && Net::Validations.normalize_mac(iface_facts[:macaddress]) != @host.mac

  def not_implemented_error(method)
    "#{method} fact parsing not implemented in #{self.class}"
  end

  def is_numeric?(string)
    begin
      !!Integer(string)
    rescue ArgumentError, TypeError
      false
    end
  end
end
