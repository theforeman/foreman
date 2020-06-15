module Host
  class Base < ApplicationRecord
    KERNEL_RELEASE_FACTS = ['kernelrelease', 'ansible_kernel', 'kernel::release', 'uname::release']

    prepend Foreman::STI
    include Authorizable
    include Parameterizable::ByName
    include DestroyFlag
    include InterfaceCloning
    include Hostext::Ownership
    include Hostext::FactData
    include Foreman::TelemetryHelper
    include Facets::BaseHostExtensions

    self.table_name = :hosts
    extend FriendlyId
    friendly_id :name

    validates_lengths_from_database
    belongs_to :model, :name_accessor => 'hardware_model_name'
    belongs_to :owner, :polymorphic => true
    has_many :fact_values, :dependent => :destroy, :foreign_key => :host_id
    has_many :fact_names, :through => :fact_values
    has_many :interfaces, -> { order(:identifier) }, :dependent => :destroy, :inverse_of => :host, :class_name => 'Nic::Base',
             :foreign_key => :host_id
    has_one :primary_interface, -> { where(:primary => true) }, :class_name => 'Nic::Base', :foreign_key => 'host_id'
    has_one :provision_interface, -> { where(:provision => true) }, :class_name => 'Nic::Base', :foreign_key => 'host_id'
    has_one :domain, :through => :primary_interface
    has_one :subnet, :through => :primary_interface
    has_one :subnet6, :through => :primary_interface
    has_one :kernel_release, -> { joins(:fact_name).where({ 'fact_names.name' => KERNEL_RELEASE_FACTS }).order('fact_names.type') }, :class_name => '::FactValue', :foreign_key => 'host_id'
    accepts_nested_attributes_for :interfaces, :allow_destroy => true

    belongs_to :location
    belongs_to :organization
    belongs_to :hostgroup

    alias_attribute :hostname, :name

    validates :name, :presence => true, :uniqueness => true, :format => {:with => Net::Validations::HOST_REGEXP, :message => _(Net::Validations::HOST_REGEXP_ERR_MSG)}
    validate :host_has_required_interfaces
    validate :uniq_interfaces_identifiers
    validate :build_managed_only

    include PxeLoaderSuggestion

    default_scope -> { where(taxonomy_conditions) }

    def self.taxonomy_conditions
      org = Organization.expand(Organization.current)
      loc = Location.expand(Location.current)
      conditions = {}
      conditions[:organization_id] = Array(org).map { |o| o.subtree_ids }.flatten.uniq unless org.nil?
      conditions[:location_id] = Array(loc).map { |l| l.subtree_ids }.flatten.uniq unless loc.nil?
      conditions
    end

    scope :no_location,     -> { rewhere(:location_id => nil) }
    scope :no_organization, -> { rewhere(:organization_id => nil) }

    delegate :ssh_authorized_keys, :to => :owner, :allow_nil => true
    delegate :notification_recipients_ids, :to => :owner, :allow_nil => true

    PRIMARY_INTERFACE_ATTRIBUTES = [:name, :ip, :ip6, :mac,
                                    :subnet, :subnet_id, :subnet_name,
                                    :subnet6, :subnet6_id, :subnet6_name,
                                    :domain, :domain_id, :domain_name,
                                    :lookup_values_attributes].freeze

    apipie :class, 'A class representing base Host object' do
      name 'Host Base'
      desc 'Methods and properties of this class are also available for managed host'
      sections only: %w[all additional]
      refs 'Host'
    end

    # primary interface is mandatory because of delegated methods so we build it if it's missing
    # similar for provision interface
    # we can't set name attribute until we have primary interface so we don't pass it to super
    # initializer and we set name when we are sure that we have primary interface
    # we can't create primary interface before calling super because args may contain nested
    # interface attributes
    def initialize(*args)
      values_for_primary_interface = {}
      build_values_for_primary_interface!(values_for_primary_interface, args)

      super(*args)

      build_required_interfaces
      update_primary_interface_attributes(values_for_primary_interface)
    end

    def dup
      super.tap do |host|
        host.interfaces << primary_interface.dup if primary_interface.present?
      end
    end

    delegate :ip, :ip6, :mac,
      :subnet, :subnet_id, :subnet_name,
      :subnet6, :subnet6_id, :subnet6_name,
      :domain, :domain_id, :domain_name,
      :hostname, :fqdn, :shortname,
      :to => :primary_interface, :allow_nil => true
    delegate :name=, :ip=, :ip6=, :mac=,
      :subnet=, :subnet_id=, :subnet_name=,
      :subnet6=, :subnet6_id=, :subnet6_name=,
      :domain=, :domain_id=, :domain_name=, :to => :primary_interface

    attr_writer :updated_virtuals
    def updated_virtuals
      @updated_virtuals ||= []
    end

    def self.attributes_protected_by_default
      super - [inheritance_column]
    end

    def self.import_host(hostname, certname = nil)
      raise(::Foreman::Exception.new("Invalid Hostname, must be a String")) unless hostname.is_a?(String)

      # downcase everything
      hostname.try(:downcase!)
      certname.try(:downcase!)

      host = Host.find_by_certname(certname) if certname.present?
      host ||= Host.find_by_name(hostname)
      host ||= new(:name => hostname) # if no host was found, build a new one

      # if we were given a certname but found the Host by hostname we should update the certname
      # this also sets certname for newly created hosts
      host.certname = certname if certname.present?

      host
    end

    def create_new_host_when_facts_are_uploaded?
      Setting[:create_new_host_when_facts_are_uploaded]
    end

    # expect a facts hash
    def import_facts(facts, source_proxy = nil)
      return false if !create_new_host_when_facts_are_uploaded? && new_record?

      # we are not importing facts for hosts in build state (e.g. waiting for a re-installation)
      raise ::Foreman::Exception.new('Host is pending for Build') if build?
      facts = facts.with_indifferent_access

      facts[:domain] = facts[:domain].downcase if facts[:domain].present?

      type = facts.delete(:_type)
      facts_importer = Foreman::Plugin.fact_importer_registry.get(type).new(self, facts)
      telemetry_observe_histogram(:importer_facts_import_duration, facts.size, type: type)
      telemetry_duration_histogram(:importer_facts_import_duration, 1000, type: type) do
        facts_importer.import!
      end

      save(:validate => false)

      parse_facts facts, type, source_proxy
    end

    def parse_facts(facts, type, source_proxy)
      time = facts[:_timestamp]
      time = time.to_time if time.is_a?(String)
      self.last_compile = time if time

      # taxonomy must be set before populate_fields_from_facts call
      set_taxonomies(facts)

      unless build?
        parser = FactParser.parser_for(type).new(facts)

        telemetry_duration_histogram(:importer_facts_import_duration, 1000, type: type) do
          populate_fields_from_facts(parser, type, source_proxy)
        end
      end

      # we are saving here with no validations, as we want this process to be as fast
      # as possible, assuming we already have all the right settings in Foreman.
      # If we don't (e.g. we never install the server via Foreman, we populate the fields from facts
      # TODO: if it was installed by Foreman and there is a mismatch,
      # we should probably send out an alert.
      save(:validate => false)
    end

    def attributes_to_import_from_facts
      [:model]
    end

    def primary_interface_type(parser)
      return unless parser.parse_interfaces?
      identifier, = parser.suggested_primary_interface(self)
      interface_class(identifier).to_s
    end

    def populate_fields_from_facts(parser, type, source_proxy)
      # we must create interface if it's missing so we can store domain
      build_required_interfaces(managed: false, type: primary_interface_type(parser))
      set_non_empty_values(parser, attributes_to_import_from_facts)
      set_interfaces(parser) if parser.parse_interfaces?
      set_comment(parser) if parser.has_comment?
    end

    def set_non_empty_values(parser, methods)
      methods.each do |attr|
        value = parser.send(attr)
        send("#{attr}=", value) if value.present?
      end
    end

    def set_interfaces(parser)
      # if host has no information in primary interface we try to match it and update it
      # instead of creating new interface, suggested primary interface mac and identifier
      # is saved to primary interface so we match it in updating code below
      if !managed? && primary_interface.mac.blank? && primary_interface.identifier.blank?
        identifier, values = parser.suggested_primary_interface(self)
        if values.present?
          logger.debug "Suggested #{identifier} NIC as a primary interface."
          primary_interface.mac = Net::Validations.normalize_mac(values[:macaddress])
          interface_klass = interface_class(identifier)
          # bridge interfaces are not attached to parent interface so save would not be possible
          if interface_klass != Nic::Bridge
            primary_interface.virtual = !!values[:virtual]
            primary_interface.attached_to = values[:attached_to] || ''
            primary_interface.tag = values[:tag] || ''
          end
        end
        primary_interface.update_attribute(:identifier, identifier)
        primary_interface.save!
      end

      changed_count = 0
      parser.interfaces.each do |name, attributes|
        iface = get_interface_scope(name, attributes).try(:first) || interface_class(name).new(:managed => false)
        # create or update existing interface
        changed_count += 1 if set_interface(attributes, name, iface)
      end

      ipmi = parser.ipmi_interface
      if ipmi.present?
        existing = interfaces.find_by(:mac => ipmi[:macaddress], :type => Nic::BMC.name)
        iface = existing || Nic::BMC.new(:managed => false)
        iface.provider ||= 'IPMI'
        changed_count += 1 if set_interface(ipmi, 'ipmi', iface)
      end
      telemetry_increment_counter(:importer_facts_count_interfaces, changed_count, type: parser.class_name_humanized)

      interfaces.reload
    end

    def set_comment(parser)
      self.comment = parser.comment
    end

    apipie :method, 'A list of facts known about the host.' do
      desc 'Note that available facts depend on what facts have been uploaded to Formean,
           typical sources are Puppet facter, subscription manager etc.
           The facts can be out of date, this macro only provides access to the value stored in the database.'
      returns Hash, desc: 'A hash of facts, keys are fact names, values are fact values'
      example '@host.facts # => { "hardwareisa"=>"x86_64", "kernel"=>"Linux", "virtual"=>"physical", ... }', desc: 'Getting all host facts'
      example '@host.facts["uptime"] # => "30 days"', desc: 'Getting specific fact value, +uptime+ in this caes'
      aliases :facts
    end
    def facts_hash
      hash = {}
      fact_values.includes(:fact_name).collect do |fact|
        hash[fact.fact_name.name] = fact.value
      end
      hash
    end
    alias_method :facts, :facts_hash

    def ==(comparison_object)
      super ||
        comparison_object.is_a?(Host::Base) &&
        id.present? &&
        comparison_object.id == id
    end

    def set_taxonomies(facts)
      ['location', 'organization'].each do |taxonomy|
        taxonomy_class = taxonomy.classify.constantize
        taxonomy_fact = Setting["#{taxonomy}_fact"]

        if taxonomy_fact.present? && facts.key?(taxonomy_fact)
          taxonomy_from_fact = taxonomy_class.find_by_title(facts[taxonomy_fact].to_s)
        else
          default_taxonomy = taxonomy_class.find_by_title(Setting["default_#{taxonomy}"])
        end

        if send(taxonomy).present?
          # Change taxonomy to fact taxonomy if set, otherwise leave it as is
          send("#{taxonomy}=", taxonomy_from_fact) unless taxonomy_from_fact.nil?
        else
          # No taxonomy was set, set to fact taxonomy or default taxonomy
          send "#{taxonomy}=", (taxonomy_from_fact || default_taxonomy)
        end
        taxonomy_class.current = send(taxonomy)
      end
    end

    def overwrite?
      @overwrite ||= false
    end

    # We have to coerce the value back to boolean. It is not done for us by the framework.
    def overwrite=(value)
      @overwrite = value.to_s == "true"
    end

    apipie :method, 'Returns a primary interface object of the host.' do
      returns 'Nic::Managed', desc: 'Host primary interface. Primary interface is the one, that defines FQDN and primary IP for the host.'
    end
    def primary_interface
      get_interface_by_flag(:primary)
    end

    apipie :method, desc: 'Returns a provision interface object of the host.' do
      returns 'Nic::Managed', desc: 'Host provisioning interface. Provisioning interface is used to determine on which interface the PXE boot should be performed. Foreman uses its subnet TFTP proxy.'
    end
    def provision_interface
      get_interface_by_flag(:provision)
    end

    apipie :method, desc: 'Returns an array of all managed interfaces objects' do
      returns array_of: 'Nic::Managed', desc: 'An array of all managed interfaces'
      example '@host.managed_interfaces.size # => 3'
    end
    def managed_interfaces
      interfaces.managed.is_managed.all
    end

    apipie :method, desc: 'Returns an array of all managed bond interfaces objects' do
      returns array_of: 'Nic::Bond', desc: 'An array of all bond interfaces'
      example '@host.bond_interfaces.map { |i| i.ip }.join(",") # => ["192.168.0.1","10.0.0.1"]'
    end
    def bond_interfaces
      interfaces.bonds.is_managed.all
    end

    apipie :method, desc: 'Returns an array of all managed bridge interfaces objects' do
      returns array_of: 'Nic::Bridge', desc: 'An array of all bridge interfaces objects'
    end
    def bridge_interfaces
      interfaces.bridges.is_managed.all
    end

    apipie :method, desc: 'Returns an array of all managed interfaces with a given identifiers' do
      required :identifiers, Array, desc: 'the list of identifiers to filter by'
      returns array_of: 'Nic::Managed', desc: 'An array of interface objects matching the given identifiers'
      example '@host.interface_with_identifier("eth1", "eth2") # => [ <#Nic::Managed ...>, <#Nic::Managed ...> ]'
    end
    def interfaces_with_identifier(identifiers)
      interfaces.is_managed.where(:identifier => identifiers).all
    end

    def reload(*args)
      drop_primary_interface_cache
      drop_provision_interface_cache
      super
    end

    def becomes(*args)
      became = super
      became.drop_primary_interface_cache
      became.drop_provision_interface_cache
      became.interfaces = interfaces
      became
    end

    def drop_primary_interface_cache
      @primary_interface = nil
    end

    def drop_provision_interface_cache
      @provision_interface = nil
    end

    def matching?
      missing_ids.empty?
    end

    def missing_ids
      Array.wrap(tax_location.try(:missing_ids)) + Array.wrap(tax_organization.try(:missing_ids))
    end

    def import_missing_ids
      tax_location.import_missing_ids     if location
      tax_organization.import_missing_ids if organization
    end

    # Provide _id aliases for consistency with the _name methods
    alias_attribute :hardware_model_id, :model_id

    def lookup_value_match
      "fqdn=#{fqdn || name}"
    end

    # we must also clone interfaces objects so we can detect their attribute changes
    # method is public because it's used when we run orchestration from interface side
    def setup_clone
      return if new_record?
      @old = super { |clone| clone.interfaces = interfaces.map { |i| setup_object_clone(i) } }
    end

    def skip_orchestration?
      false
    end

    def orchestrated?
      self.class.included_modules.include?(Orchestration)
    end

    def render_template(template:, **params)
      template.render(host: self, **params)
    end

    private

    def parse_ip_address(address, ignore_link_local: true)
      return nil unless address

      begin
        addr = IPAddr.new(address)
      rescue IPAddr::InvalidAddressError
        # https://tickets.puppetlabs.com/browse/FACT-1935 facter can return an
        # address with the link local identifier. Ruby can't parse because of
        # https://bugs.ruby-lang.org/issues/8464 so we manually strip it off
        # if the interface identifier if present
        if address.is_a?(String) && address.include?('%')
          addr = IPAddr.new(address.split('%').first)
        else
          logger.warn "Ignoring invalid IP address #{address}"
          return nil
        end
      end

      if ignore_link_local
        # Ruby 2.5 introduced IPAddr#link_local?
        if addr.respond_to?(:link_local?)
          return if addr.link_local?
        else
          return if addr.ipv4? && IPAddr.new('169.254.0.0/16').include?(addr)
          return if addr.ipv6? && IPAddr.new('fe80::/10').include?(addr)
        end
      end

      addr.to_s
    end

    def build_values_for_primary_interface!(values_for_primary_interface, args)
      new_attrs = args.shift
      unless new_attrs.nil?
        new_attrs = new_attrs.with_indifferent_access
        values_for_primary_interface[:name] = NameGenerator.new.next_random_name unless new_attrs.has_key?(:name)
        PRIMARY_INTERFACE_ATTRIBUTES.each do |attr|
          values_for_primary_interface[attr] = new_attrs.delete(attr) if new_attrs.has_key?(attr)
        end

        model_name = new_attrs.delete(:model_name)
        new_attrs[:hardware_model_name] = model_name if model_name.present?

        args.unshift(new_attrs)
      end
    end

    def update_primary_interface_attributes(attrs)
      attrs.each do |name, value|
        send "#{name}=", value
      end
    end

    def tax_location
      return nil unless location_id
      @tax_location ||= TaxHost.new(location, self)
    end

    def tax_organization
      return nil unless organization_id
      @tax_organization ||= TaxHost.new(organization, self)
    end

    def build_required_interfaces(attrs = {})
      if primary_interface.nil?
        if interfaces.empty?
          attrs[:type] ||= 'Nic::Managed'
          interfaces.build(attrs.merge(primary: true))
        else
          interface = interfaces.first
          interface.attributes = attrs
          interface.primary = true
        end
      elsif attrs[:type] && primary_interface.type != attrs[:type]
        primary_interface.type = attrs[:type]
        if primary_interface.persisted?
          if primary_interface.save(validate: false)
            interfaces.reload
            provision_interface&.reload
          else
            logger.error "Unable to convert interface #{self} from #{primary_interface.type} to #{attrs[:type]}: #{primary_interface.errors.full_messages.to_sentence}"
          end
        end
      end
      primary_interface.provision = true if provision_interface.nil?
    end

    def get_interface_scope(name, attributes, base = interfaces)
      case interface_class(name).to_s
        # we search bonds based on identifiers, e.g. ubuntu sets random MAC after each reboot se we can't
        # rely on mac
        when 'Nic::Bond', 'Nic::Bridge'
          base.where(:identifier => name)
        # for other interfaces we distinguish between virtual and physical interfaces
        # for virtual devices we don't check only mac address since it's not unique,
        # if we want to update the device it must have same identifier
        else
          begin
            macaddress = Net::Validations.normalize_mac(attributes[:macaddress])
          rescue Net::Validations::Error
            logger.debug "invalid mac during parsing: #{attributes[:macaddress]}"
          end

          mac_based = base.where(:mac => macaddress)
          if attributes[:virtual]
            mac_based.virtual.where(:identifier => name) || find_by_attached_mac(base, mac_based, identifier, attributes)
          elsif mac_based.physical.any?
            mac_based.physical
          elsif !managed
            # Unmanaged host's interfaces are just used for reporting, so overwrite based on identifier first
            base.where(:identifier => name)
          end
      end
    end

    def find_by_attached_mac(base, mac_based, identifier, attributes)
      ifaces = base.where(:attached_to => mac_based.first&.identifier)
      (ifaces.size > 1) ? ifaces.where(:tag => attributes[:tag]) : ifaces
    end

    def update_bonds(iface, name, attributes)
      bond_interfaces.each do |bond|
        next unless bond.children_mac_addresses.include?(attributes['macaddress'])
        next if bond.attached_devices_identifiers.include? name
        update_bond bond, iface, name
      end
    end

    def update_bond(bond, iface, name)
      if iface&.identifier
        bond.remove_device(iface.identifier)
        bond.add_device(name)
        logger.debug "Updating bond #{bond.identifier}, id #{bond.id}: removing #{iface.identifier}, adding #{name} to attached interfaces"
        save_updated_bond bond
      end
    end

    def save_updated_bond(bond)
      bond.save!
    rescue StandardError => e
      logger.warn "Saving #{bond.identifier} NIC for host #{name} failed, skipping because #{e.message}:"
      bond.errors.full_messages.each { |message| logger.warn " #{message}" }
    end

    def update_subnet_from_facts(iface, keep_subnet)
      return if Setting[:update_subnets_from_facts] == 'none' || keep_subnet
      return if Setting[:update_subnets_from_facts] == 'provision' && !iface.provision
      iface.subnet = Subnet.subnet_for(iface.ip) if iface.ip_changed? && !iface.matches_subnet?(:ip, :subnet)
      iface.subnet6 = Subnet.subnet_for(iface.ip6) if iface.ip6_changed? && !iface.matches_subnet?(:ip6, :subnet6)
    end

    def set_interface(attributes, name, iface)
      # update bond.attached_interfaces when interface is in the list and identifier has changed
      update_bonds(iface, name, attributes) if iface.identifier != name && !iface.virtual? && iface.persisted?
      attributes = attributes.clone
      iface.mac = attributes.delete(:macaddress)
      iface.ip = parse_ip_address(attributes.delete(:ipaddress))
      iface.ip6 = parse_ip_address(attributes.delete(:ipaddress6))

      update_subnet_from_facts(iface, attributes.delete(:keep_subnet))

      iface.virtual = attributes.delete(:virtual) || false
      iface.tag = attributes.delete(:tag) || ''
      iface.attached_to = attributes.delete(:attached_to) if attributes[:attached_to].present?
      iface.link = attributes.delete(:link) if attributes.has_key?(:link)
      iface.identifier = name
      iface.host = self
      update_virtuals(iface.identifier_was, name) if iface.identifier_changed? && !iface.virtual? && iface.persisted? && iface.identifier_was.present?
      iface.attrs = attributes

      if iface.new_record? || iface.changed?
        logger.debug "Saving #{name} NIC for host #{self.name}"
        result = iface.save_without_auditing

        unless result
          logger.warn "Saving #{name} NIC for host #{self.name} failed, skipping because:"
          iface.errors.full_messages.each { |e| logger.warn " #{e}" }
        end

        result
      end
    end

    def update_virtuals(old, new)
      self.updated_virtuals ||= []

      interfaces.where(:attached_to => old).virtual.each do |virtual_interface|
        next if self.updated_virtuals.include?(virtual_interface.id) # may have been already renamed by another physical

        virtual_interface.attached_to = new
        virtual_interface.identifier = virtual_interface.identifier.sub(old, new)
        virtual_interface.save!
        self.updated_virtuals.push(virtual_interface.id)
      end
    end

    def interface_class(name)
      case name
        when FactParser::BONDS
          Nic::Bond
        when FactParser::BRIDGES
          Nic::Bridge
        else
          Nic::Managed
      end
    end

    # we can't use SQL query for new records, because interfaces may not exist yet
    def get_interface_by_flag(flag)
      if new_record?
        interfaces.detect(&flag)
      else
        cache = "@#{flag}_interface"
        if (result = instance_variable_get(cache))
          result
        else
          # we can't use SQL, we need to get even unsaved objects
          interface = interfaces.detect(&flag)

          interface.host = self if interface && !interface.destroyed? # inverse_of does not help (STI), but ignore this on deletion
          instance_variable_set(cache, interface)
        end
      end
    end

    # we require primary interface so have know the name of host
    # provision is required only for managed host and defaults to primary
    def host_has_required_interfaces
      check_primary_interface
      check_provision_interface if managed?
    end

    def check_primary_interface
      if primary_interface.nil?
        errors.add :interfaces, _("host must have one primary interface")
      end
    end

    def check_provision_interface
      if provision_interface.nil?
        errors.add :interfaces, _("managed host must have one provision interface")
      end
    end

    # we can't use standard unique validation on interface since we can't properly handle :scope => :host_id
    # for new hosts host_id does not exist at that moment, validation would work only for persisted records
    def uniq_interfaces_identifiers
      success = true
      identifiers = []
      relevant_interfaces = interfaces.select { |i| !i.marked_for_destruction? }
      relevant_interfaces.each do |interface|
        next if interface.identifier.blank?
        if identifiers.include?(interface.identifier)
          interface.errors.add :identifier, :taken
          success = false
        end
        identifiers.push(interface.identifier)
      end

      errors.add(:interfaces, _('some interfaces are invalid')) unless success
      success
    end

    def build_managed_only
      if !managed? && build?
        errors.add(:build, _('cannot be enabled for an unmanaged host'))
      end
    end

    def password_base64_encrypted?
      if root_pass_changed?
        root_pass == hostgroup.try(:read_attribute, :root_pass)
      else
        true
      end
    end
  end
end

require_dependency 'host/managed'
