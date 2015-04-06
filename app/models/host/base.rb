module Host
  class Base < ActiveRecord::Base
    include Foreman::STI
    include Authorizable
    include CounterCacheFix
    include Parameterizable::ByName

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
    accepts_nested_attributes_for :interfaces, :reject_if => lambda { |a| a[:mac].blank? }, :allow_destroy => true

    belongs_to :location
    belongs_to :organization

    alias_attribute :hostname, :name
    before_validation :normalize_name
    validates :name, :presence   => true, :uniqueness => true, :format => {:with => Net::Validations::HOST_REGEXP}
    validates :owner_type, :inclusion => { :in          => OWNER_TYPES,
                                           :allow_blank => true,
                                           :message     => (_("Owner type needs to be one of the following: %s") % OWNER_TYPES.join(', ')) }

    default_scope lambda {
      org = Organization.expand(Organization.current)
      loc = Location.expand(Location.current)
      conditions = {}
      conditions[:organization_id] = Array(org).map { |o| o.subtree_ids }.flatten.uniq if org.present?
      conditions[:location_id] = Array(loc).map { |l| l.subtree_ids }.flatten.uniq if loc.present?
      where(conditions)
    }

    scope :no_location, lambda { where(:location_id => nil) }
    scope :no_organization, lambda { where(:organization_id => nil) }

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

      set_non_empty_values(parser, attributes_to_import_from_facts)
      set_interfaces(parser)

      parser
    end

    def set_non_empty_values(parser, methods)
      methods.each do |attr|
        value = parser.send(attr)
        self.send("#{attr}=", value) unless value.blank?
      end
    end

    def set_interfaces(parser)
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
          # for physical devices we ignore primary interface which is updated by other facts
          # we just update its name and log it
          if macaddress != Net::Validations.normalize_mac(self.mac)
            base = base.physical
          else
            logger.debug "Skipping #{name} since it is primary interface of host #{self.name}"
            old = self.primary_interface
            self.update_attribute :primary_interface, name
            update_virtuals(old, name) if old != name && old.present?
            next
          end
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

    def normalize_name
      self.name = Net::Validations.normalize_hostname(name) if self.name.present?
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

    def has_primary_interface?
      self.primary_interface.present?
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

    private

    def tax_location
      return nil unless location_id
      @tax_location ||= TaxHost.new(location, self)
    end

    def tax_organization
      return nil unless organization_id
      @tax_organization ||= TaxHost.new(organization, self)
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
  end
end
