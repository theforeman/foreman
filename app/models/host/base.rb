module Host
  class Base < ActiveRecord::Base
    include Foreman::STI
    include Authorizable
    include CounterCacheFix
    include Parameterizable::ByName
    include DestroyFlag

    self.table_name = :hosts
    extend FriendlyId
    friendly_id :name
    OWNER_TYPES = %w(User Usergroup)

    validates_lengths_from_database
    belongs_to :model, :counter_cache => :hosts_count
    has_many :fact_values, :dependent => :destroy, :foreign_key => :host_id
    has_many :fact_names, :through => :fact_values
    has_many :interfaces, :dependent => :destroy, :inverse_of => :host, :class_name => 'Nic::Base',
             :foreign_key => :host_id, :order => 'identifier'
    has_one :primary_interface, :class_name => 'Nic::Base', :foreign_key => 'host_id',
            :conditions => { :primary => true }
    has_one :provision_interface, :class_name => 'Nic::Base', :foreign_key => 'host_id',
            :conditions => { :provision => true }
    has_one :domain, :through => :primary_interface
    has_one :subnet, :through => :primary_interface
    accepts_nested_attributes_for :interfaces, :allow_destroy => true

    alias_attribute :hostname, :name
    validates :name, :presence   => true, :uniqueness => true, :format => {:with => Net::Validations::HOST_REGEXP}
    validates :owner_type, :inclusion => { :in          => OWNER_TYPES,
                                           :allow_blank => true,
                                           :message     => (_("Owner type needs to be one of the following: %s") % OWNER_TYPES.join(', ')) }
    validate :host_has_required_interfaces

    # primary interface is mandatory because of delegated methods so we build it if it's missing
    # similar for provision interface
    # we can't set name attribute until we have primary interface so we don't pass it to super
    # initializer and we set name when we are sure that we have primary interface
    # we can't create primary interface before calling super because args may contain nested
    # interface attributes
    def initialize(*args)
      primary_interface_attrs = [:name, :ip, :mac,
                                 :subnet, :subnet_id, :subnet_name,
                                 :domain, :domain_id, :domain_name,
                                 :lookup_values_attributes]
      values_for_primary_interface = {}

      new_attrs = args.shift
      unless new_attrs.nil?
        new_attrs = new_attrs.with_indifferent_access
        primary_interface_attrs.each do |attr|
          values_for_primary_interface[attr] = new_attrs.delete(attr) if new_attrs.has_key?(attr)
        end
        args.unshift(new_attrs.to_hash)
      end

      super(*args)

      build_required_interfaces
      values_for_primary_interface.each do |name, value|
        self.send "#{name}=", value
      end
    end

    delegate :ip, :mac,
             :subnet, :subnet_id, :subnet_name,
             :domain, :domain_id, :domain_name,
             :hostname,
             :to => :primary_interface, :allow_nil => true
    delegate :name=, :ip=, :mac=, :subnet=, :subnet_id=, :subnet_name=,
             :domain=, :domain_id=, :domain_name=, :to => :primary_interface

    attr_writer :updated_virtuals
    def updated_virtuals
      @updated_virtuals ||= []
    end

    def self.attributes_protected_by_default
      super - [ inheritance_column ]
    end

    def self.import_host_and_facts(json)
      # noop, overridden by STI descendants
      [self, true]
    end

    # expect a facts hash
    def import_facts(facts)
      # we are not importing facts for hosts in build state (e.g. waiting for a re-installation)
      raise ::Foreman::Exception.new('Host is pending for Build') if build?

      time = facts[:_timestamp]
      time = time.to_time if time.is_a?(String)

      # we are not doing anything we already processed this fact (or a newer one)
      if time
        return true unless last_compile.nil? or (last_compile + 1.minute < time)
        self.last_compile = time
      end

      type = facts.delete(:_type) || 'puppet'
      importer = FactImporter.importer_for(type).new(self, facts)
      importer.import!

      save(:validate => false)
      populate_fields_from_facts(facts, type)
      set_taxonomies(facts)

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
        self.primary_interface.mac = Net::Validations.normalize_mac(values[:macaddress])
        self.primary_interface.identifier = identifier
        self.primary_interface.save!
      end

      parser.interfaces.each do |name, attributes|
        begin
          macaddress = Net::Validations.normalize_mac(attributes[:macaddress])
        rescue ArgumentError
          logger.debug "invalid mac during parsing: #{attributes[:macaddress]}"
        end
        base = self.interfaces.where(:mac => macaddress)

        if attributes[:virtual]
          # for virtual devices we don't check only mac address since it's not unique,
          # if we want to update the device it must have same identifier
          base = base.virtual.where(:identifier => name)
        else
          base = base.physical
        end

        iface = base.first || interface_class(name).new(:managed => false)
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
          taxonomy_from_fact = taxonomy_class.find_by_title(facts[taxonomy_fact])
        else
          default_taxonomy = taxonomy_class.find_by_title(Setting["default_#{taxonomy}"])
        end

        if self.send("#{taxonomy}").present?
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

    def self.find_by_ip(ip)
      logger.warn 'DEPRECATION WARNING: Host#find_by_ip has been deprecated, you should search for primary interfaces'
      Nic::Base.primary.find_by_ip(ip).try(:host)
    end

    def self.find_by_mac(mac)
      logger.warn 'DEPRECATION WARNING: Host#find_by_mac has been deprecated, you should search for provision interfaces'
      Nic::Base.provision.find_by_mac(mac).try(:host)
    end

    private

    def build_required_interfaces(attrs = {})
      self.interfaces.build(attrs.merge(:primary => true, :type => 'Nic::Managed')) if self.primary_interface.nil?
      self.primary_interface.provision = true if self.provision_interface.nil?
    end

    def set_interface(attributes, name, iface)
      attributes = attributes.clone
      iface.mac = attributes.delete(:macaddress)
      iface.ip = attributes.delete(:ipaddress)
      iface.virtual = attributes.delete(:virtual) || false
      iface.tag = attributes.delete(:tag) || ''
      iface.attached_to = attributes.delete(:attached_to) || ''
      iface.link = attributes.delete(:link) if attributes.has_key?(:link)
      iface.identifier = name
      iface.host = self
      update_virtuals(iface.identifier_was, name) if iface.identifier_changed? && !iface.virtual? && iface.persisted?
      iface.attrs = attributes

      logger.debug "Saving #{name} NIC for host #{self.name}"
      result = iface.save
      result or begin
        logger.warn "Saving #{name} NIC for host #{self.name} failed, skipping because:"
        iface.errors.full_messages.each { |e| logger.warn " #{e}"}
        false
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

          interface.host = self if interface # inverse_of does not help (STI), but ignore this on deletion (interface is not found)
          instance_variable_set(cache, interface)
        end
      end
    end

    # we require primary interface so have know the name of host
    # provision is required only for managed host and defaults to primary
    def host_has_required_interfaces
      check_primary_interface
      if self.managed?
        check_provision_interface
      end
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
  end
end
