class FactParser
  delegate :logger, :to => :Rails
  VIRTUAL = '\A([a-z0-9]+)_(\d+)\Z'
  BRIDGES = '\A(vir)?br\d+\Z'
  VIRTUAL_NAMES = /#{VIRTUAL}|#{BRIDGES}/

  def self.parser_for(type)
    parsers[type.to_s] || parsers[:puppet]
  end

  def self.parsers
    @parsers ||= { :puppet => PuppetFactParser }.with_indifferent_access
  end

  def self.register_fact_importer(key, klass)
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

  def primary_interface
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
    result = {}

    interfaces = get_interfaces
    interfaces = remove_ignored(normalize_interfaces(interfaces))
    logger.debug "We have following interfaces '#{interfaces.join(', ')}' based on facts"

    interfaces.each do |interface|
      iface_facts = get_facts_for_interface(interface)
      iface_facts = set_additional_attributes(iface_facts, interface)
      result[interface] = iface_facts
    end
    result.with_indifferent_access
  end

  # TODO: Remove these method once interfaces management is enabled
  def mac
    raise NotImplementedError, not_implemented_error(__method__)
  end

  def ip
    raise NotImplementedError, not_implemented_error(__method__)
  end

  def certname
    raise NotImplementedError, not_implemented_error(__method__)
  end

  def support_interfaces_parsing?
    false
  end

  def parse_interfaces?
    support_interfaces_parsing? && !Setting['ignore_puppet_facts_for_provisioning']
  end

  private

  # adds attributes like virtual
  def set_additional_attributes(attributes, name)
    if name =~ VIRTUAL_NAMES
      attributes[:virtual] = true
      if $1.nil?
        attributes[:bridge] = true
      else
        attributes[:physical_device] = $1

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
    /\A(lo|usb|vnet)/
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
