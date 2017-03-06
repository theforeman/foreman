module Host
  class Base < ActiveRecord::Base
    include Foreman::STI
    include Authorizable
    include Parameterizable::ByName
    include DestroyFlag
    include InterfaceCloning

    self.table_name = :hosts
    extend FriendlyId
    friendly_id :name
    OWNER_TYPES = %w(User Usergroup)

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
    accepts_nested_attributes_for :interfaces, :allow_destroy => true

    belongs_to :location
    belongs_to :organization

    alias_attribute :hostname, :name
    before_validation :set_default_user

    validates :name, :presence   => true, :uniqueness => true, :format => {:with => Net::Validations::HOST_REGEXP}
    validates :owner_type, :inclusion => { :in          => OWNER_TYPES,
                                           :allow_blank => true,
                                           :message     => (_("Owner type needs to be one of the following: %s") % OWNER_TYPES.join(', ')) }
    validate :validate_owner
    validate :host_has_required_interfaces
    validate :uniq_interfaces_identifiers
    validate :build_managed_only
    validate :owner_taxonomies_match, :if => Proc.new { |host| host.owner.is_a?(User) }

    include PxeLoaderSuggestion

    default_scope -> { where(taxonomy_conditions) }

    def self.taxonomy_conditions
      org = Organization.expand(Organization.current) if SETTINGS[:organizations_enabled]
      loc = Location.expand(Location.current) if SETTINGS[:locations_enabled]
      conditions = {}
      conditions[:organization_id] = Array(org).map { |o| o.subtree_ids }.flatten.uniq unless org.nil?
      conditions[:location_id] = Array(loc).map { |l| l.subtree_ids }.flatten.uniq unless loc.nil?
      conditions
    end

    scope :no_location,     -> { rewhere(:location_id => nil) }
    scope :no_organization, -> { rewhere(:organization_id => nil) }

    PRIMARY_INTERFACE_ATTRIBUTES = [:name, :ip, :ip6, :mac,
                                    :subnet, :subnet_id, :subnet_name,
                                    :subnet6, :subnet6_id, :subnet6_name,
                                    :domain, :domain_id, :domain_name,
                                    :lookup_values_attributes].freeze

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
        host.interfaces << self.primary_interface.dup if self.primary_interface.present?
      end
    end

    delegate :ip, :ip6, :mac,
             :subnet, :subnet_id, :subnet_name,
             :subnet6, :subnet6_id, :subnet6_name,
             :domain, :domain_id, :domain_name,
             :hostname, :fqdn, :fqdn_changed?,
             :fqdn_was, :shortname,
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
      super - [ inheritance_column ]
    end

    def create_new_host_when_facts_are_uploaded?
      Setting[:create_new_host_when_facts_are_uploaded]
    end

    # expect a facts hash
    def import_facts(facts)
      return false if !create_new_host_when_facts_are_uploaded? && new_record?

      # we are not importing facts for hosts in build state (e.g. waiting for a re-installation)
      raise ::Foreman::Exception.new('Host is pending for Build') if build?
      facts = facts.with_indifferent_access

      facts[:domain] = facts[:domain].downcase if facts[:domain].present?

      time = facts[:_timestamp]
      time = time.to_time if time.is_a?(String)
      self.last_compile = time if time

      type = facts.delete(:_type) || 'puppet'
      importer = FactImporter.importer_for(type).new(self, facts)
      importer.import!

      save(:validate => false)
      set_taxonomies(facts)
      populate_fields_from_facts(facts, type)

      # we are saving here with no validations, as we want this process to be as fast
      # as possible, assuming we already have all the right settings in Foreman.
      # If we don't (e.g. we never install the server via Foreman, we populate the fields from facts
      # TODO: if it was installed by Foreman and there is a mismatch,
      # we should probably send out an alert.
      save(:validate => false)
    end

    def attributes_to_import_from_facts
      [ :model ]
    end

    def populate_fields_from_facts(facts = self.facts_hash, type = 'puppet')
      # we don't import facts for host in build mode
      return if build?

      parser = FactParser.parser_for(type).new(facts)

      # we must create interface if it's missing so we can store domain
      build_required_interfaces(:managed => false)
      set_non_empty_values(parser, attributes_to_import_from_facts)
      set_interfaces(parser) if parser.parse_interfaces?
      parser
    end

    def set_non_empty_values(parser, methods)
      methods.each do |attr|
        value = parser.send(attr)
        self.send("#{attr}=", value) unless value.blank?
      end
    end

    def set_interfaces(parser)
      # if host has no information in primary interface we try to match it and update it
      # instead of creating new interface, suggested primary interface mac and identifier
      # is saved to primary interface so we match it in updating code below
      if !self.managed? && self.primary_interface.mac.blank? && self.primary_interface.identifier.blank?
        identifier, values = parser.suggested_primary_interface(self)
        self.primary_interface.mac = Net::Validations.normalize_mac(values[:macaddress]) if values.present?
        self.primary_interface.update_attribute(:identifier, identifier)
        self.primary_interface.save!
      end

      parser.interfaces.each do |name, attributes|
        iface = get_interface_scope(name, attributes).try(:first) || interface_class(name).new(:managed => false)
        # create or update existing interface
        set_interface(attributes, name, iface)
      end

      ipmi = parser.ipmi_interface
      if ipmi.present?
        existing = self.interfaces.where(:mac => ipmi[:macaddress], :type => Nic::BMC).first
        iface = existing || Nic::BMC.new(:managed => false)
        iface.provider ||= 'IPMI'
        set_interface(ipmi, 'ipmi', iface)
      end

      self.interfaces.reload
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
        next unless SETTINGS["#{taxonomy.pluralize}_enabled".to_sym]
        taxonomy_class = taxonomy.classify.constantize
        taxonomy_fact = Setting["#{taxonomy}_fact"]

        if taxonomy_fact.present? && facts.keys.include?(taxonomy_fact)
          taxonomy_from_fact = taxonomy_class.find_by_title(facts[taxonomy_fact].to_s)
        else
          default_taxonomy = taxonomy_class.find_by_title(Setting["default_#{taxonomy}"])
        end

        if self.send(taxonomy.to_s).present?
          # Change taxonomy to fact taxonomy if set, otherwise leave it as is
          self.send("#{taxonomy}=", taxonomy_from_fact) unless taxonomy_from_fact.nil?
        else
          # No taxonomy was set, set to fact taxonomy or default taxonomy
          self.send "#{taxonomy}=", (taxonomy_from_fact || default_taxonomy)
        end
      end
    end

    def overwrite?
      @overwrite ||= false
    end

    # We have to coerce the value back to boolean. It is not done for us by the framework.
    def overwrite=(value)
      @overwrite = value.to_s == "true"
    end

    def primary_interface
      get_interface_by_flag(:primary)
    end

    def provision_interface
      get_interface_by_flag(:provision)
    end

    def managed_interfaces
      self.interfaces.managed.is_managed.all
    end

    def bond_interfaces
      self.interfaces.bonds.is_managed.all
    end

    def bridge_interfaces
      self.interfaces.bridges.is_managed.all
    end

    def interfaces_with_identifier(identifiers)
      self.interfaces.is_managed.where(:identifier => identifiers).all
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
      became.interfaces = self.interfaces
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
      @old = super { |clone| clone.interfaces = self.interfaces.map {|i| setup_object_clone(i) } }
    end

    def skip_orchestration?
      false
    end

    private

    def owner_taxonomies_match
      return true if self.owner.admin?

      if Organization.organizations_enabled && self.organization_id && !self.owner.my_organizations.where(:id => self.organization_id).exists?
        errors.add :is_owned_by, _("does not belong into host's organization")
      end
      if Location.locations_enabled && self.location_id && !self.owner.my_locations.where(:id => self.location_id).exists?
        errors.add :is_owned_by, _("does not belong into host's location")
      end
    end

    def set_default_user
      self.owner ||= User.current if self.owner_type.nil? && self.owner_id.nil?
      true
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
        self.send "#{name}=", value
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
      if self.primary_interface.nil?
        if self.interfaces.empty?
          self.interfaces.build(attrs.merge(:primary => true, :type => 'Nic::Managed'))
        else
          interface = self.interfaces.first
          interface.attributes = attrs
          interface.primary = true
        end
      end
      self.primary_interface.provision = true if self.provision_interface.nil?
    end

    def get_interface_scope(name, attributes, base = self.interfaces)
      case interface_class(name).to_s
        # we search bonds based on identifiers, e.g. ubuntu sets random MAC after each reboot se we can't
        # rely on mac
        when 'Nic::Bond', 'Nic::Bridge'
          base.virtual.where(:identifier => name)
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
            mac_based.virtual.where(:identifier => name)
          elsif mac_based.physical.any?
            mac_based.physical
          elsif !self.managed
            #Unmanaged host's interfaces are just used for reporting, so overwrite based on identifier first
            base.where(:identifier => name)
          end
      end
    end

    def set_interface(attributes, name, iface)
      attributes = attributes.clone
      iface.mac = attributes.delete(:macaddress)
      iface.ip = attributes.delete(:ipaddress)
      iface.ip6 = attributes.delete(:ipaddress6)

      if Setting[:update_subnets_from_facts]
        iface.subnet = Subnet.subnet_for(iface.ip) if iface.ip_changed? && !iface.matches_subnet?(:ip, :subnet)
        iface.subnet6 = Subnet.subnet_for(iface.ip6) if iface.ip6_changed? && !iface.matches_subnet?(:ip6, :subnet6)
      end

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
        result = iface.save

        unless result
          logger.warn "Saving #{name} NIC for host #{self.name} failed, skipping because:"
          iface.errors.full_messages.each { |e| logger.warn " #{e}" }
        end

        result
      end
    end

    def update_virtuals(old, new)
      self.updated_virtuals ||= []

      self.interfaces.where(:attached_to => old).virtual.each do |virtual_interface|
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
      if self.new_record?
        self.interfaces.detect(&flag)
      else
        cache = "@#{flag}_interface"
        if (result = instance_variable_get(cache))
          result
        else
          # we can't use SQL, we need to get even unsaved objects
          interface = self.interfaces.detect(&flag)

          interface.host = self if interface && !interface.destroyed? # inverse_of does not help (STI), but ignore this on deletion
          instance_variable_set(cache, interface)
        end
      end
    end

    # we require primary interface so have know the name of host
    # provision is required only for managed host and defaults to primary
    def host_has_required_interfaces
      check_primary_interface
      check_provision_interface if self.managed?
    end

    def check_primary_interface
      if self.primary_interface.nil?
        errors.add :interfaces, _("host must have one primary interface")
      end
    end

    def check_provision_interface
      if self.provision_interface.nil?
        errors.add :interfaces, _("managed host must have one provision interface")
      end
    end

    # we can't use standard unique validation on interface since we can't properly handle :scope => :host_id
    # for new hosts host_id does not exist at that moment, validation would work only for persisted records
    def uniq_interfaces_identifiers
      success = true
      identifiers = []
      relevant_interfaces = self.interfaces.select { |i| !i.marked_for_destruction? }
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

    def validate_owner
      return true if self.owner_type.nil? && self.owner.nil?

      add_owner_error if self.owner_type.present? && self.owner.nil?
    end

    def add_owner_error
      if self.owner_id.present?
        errors.add(:owner, (_('There is no owner with id %d and type %s') % [self.owner_id, self.owner_type]))
      else
        errors.add(:owner, _('If owner type is specified, owner must be specified too.'))
      end
    end
  end
end

require_dependency 'host/managed'
