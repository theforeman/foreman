class FactParser
  delegate :logger, :to => :Rails
  VIRTUAL = /\A([a-z0-9]+)[_|\.|:]([a-z0-9]+)\Z/
  BRIDGES = /\A(vir|lxc)?br(\d+|-[a-z0-9]+)(_nic)?\Z/
  BONDS = /\A(bond\d+)\Z|\A(lagg\d+)\Z/
  ALIASES = /(\A[a-z0-9\.]+):([a-z0-9]+)\Z/
  VLANS = /\A([a-z0-9]+)\.([0-9]+)\Z/
  VIRTUAL_NAMES = /#{ALIASES}|#{VLANS}|#{VIRTUAL}|#{BRIDGES}|#{BONDS}/

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

  def comment
    facts[:foreman_comment]
  end

  def has_comment?
    facts.key?(:foreman_comment)
  end

  def hostgroup
    hostgroup_title = facts[:foreman_hostgroup]
    Hostgroup.unscoped.where(:title => hostgroup_title).first_or_create if hostgroup_title.present?
  end

  # should return hash with indifferent access in following format:
  #   {
  #      'eth0': {'link': 'true', 'macaddress': '00:00:00:00:00:FF', 'ipaddress': nil, 'any_other_fact': 'value'},
  #      'eth0.0': { ... }
  #   }
  def interfaces
    @interfaces ||= begin
      result = {}

      interfaces = remove_ignored(get_interfaces)
      logger.debug { "We have following interfaces '#{interfaces.join(', ')}' based on facts" }

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
    support_interfaces_parsing? && !Setting['ignore_puppet_facts_for_provisioning']
  end

  def class_name_humanized
    @class_name_humanized ||= self.class.name.demodulize.underscore
  end

  # timestamp (unix epoch based) when the host has booted, e.g. 1563281738
  # should return nil if the parser does not support this information
  def boot_timestamp
    nil
  end

  # is host virtual?
  def virtual
  end

  # host memory in MB
  def ram
  end

  # number of CPU sockets
  def sockets
  end

  # cores per socket
  def cores
  end

  # The summed total size (in bytes) of all disks of a host or nil if unsupported
  def disks_total
  end

  private

  def find_interface_by_name(host_name)
    interfaces.detect do |int, values|
      if (ip = values[:ipaddress]).present?
        begin
          if Resolv::DNS.new.getnames(ip).any? { |name| name.to_s == host_name }
            logger.debug { "resolved #{host_name} for #{ip}, #{int} is selected as primary" }
            return [int, values]
          end
        rescue Resolv::ResolvError => e
          logger.debug { "could not resolv name for #{ip} because of #{e} #{e.message}" }
          nil
        end
      end
    end
  end

  def find_physical_interface(interfaces)
    interfaces.detect { |int, _| int.to_s !~ FactParser::VIRTUAL_NAMES }
  end

  def find_virtual_interface(interfaces)
    interfaces.detect { |int, _| int.to_s =~ FactParser::VIRTUAL_NAMES }
  end

  # adds attributes like virtual
  def set_additional_attributes(attributes, name)
    if name =~ VIRTUAL_NAMES
      attributes[:virtual] = true
      if Regexp.last_match(1).nil? && name =~ BRIDGES
        attributes[:bridge] = true
      elsif name =~ ALIASES
        attributes[:attached_to] = Regexp.last_match(1)
        attributes[:tag] = ''
      elsif name =~ VLANS
        attributes[:attached_to] = Regexp.last_match(1)
        attributes[:tag] = Regexp.last_match(2)
      elsif name =~ VIRTUAL
        # Legacy: facter < v3.0
        # vlans fact has been removed in facter 3.0
        attributes[:attached_to] = Regexp.last_match(1)
        tag = Regexp.last_match(2)
        if @facts[:vlans].present?
          vlans = @facts[:vlans].split(',')
          attributes[:tag] = vlans.include?(tag) ? tag : ''
        else
          attributes[:tag] = name.split('.').last
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
    @ignored_interfaces ||= Setting.convert_array_to_regexp(Setting[:ignored_interface_identifiers])
  end

  def remove_ignored(interfaces)
    interfaces.clone.delete_if do |identifier|
      if (remove = identifier.match(ignored_interfaces))
        logger.debug { "skipping interface with identifier '#{identifier}' since it was matched by 'ignored_interface_identifiers' setting " }
      end
      remove
    end
  end

  # creating if iface_facts[:link] == 'true' && Net::Validations.normalize_mac(iface_facts[:macaddress]) != @host.mac

  def not_implemented_error(method)
    "#{method} fact parsing not implemented in #{self.class}"
  end
end
