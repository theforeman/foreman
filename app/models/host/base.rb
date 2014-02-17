require 'facts_parser'

module Host
  class Base < ActiveRecord::Base
    include Foreman::STI
    include Authorizable
    self.table_name = :hosts
    OWNER_TYPES = %w(User Usergroup)

    belongs_to :model
    has_many :fact_values, :dependent => :destroy, :foreign_key => :host_id
    has_many :fact_names, :through => :fact_values

    alias_attribute        :hostname, :name
    before_validation      :normalize_name
    validates :name,       :presence => true,
                           :uniqueness => true,
                           :format => {:with => Net::Validations::HOST_REGEXP}
    validates_inclusion_of :owner_type,
                           :in          => OWNER_TYPES,
                           :allow_blank => true,
                           :message     => (_("Owner type needs to be one of the following: %s") % OWNER_TYPES.join(', '))

    def self.attributes_protected_by_default
      super - [ inheritance_column ]
    end

    def self.importHostAndFacts json
      # noop, overridden by STI descendants
      return self, true
    end

    # expect a facts hash
    def importFacts facts
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
      FactImporter.importer_for(type).new(self, facts).import!

      save(:validate => false)
      populateFieldsFromFacts(facts)

      # we are saving here with no validations, as we want this process to be as fast
      # as possible, assuming we already have all the right settings in Foreman.
      # If we don't (e.g. we never install the server via Foreman, we populate the fields from facts
      # TODO: if it was installed by Foreman and there is a mismatch,
      # we should probably send out an alert.
      return save(:validate => false)
    end

    def attributes_to_import_from_facts
      attrs = [:model]
    end

    def populateFieldsFromFacts facts = self.facts_hash
      # we don't import facts for host in build mode
      return if build?

      importer = Facts::Parser.new facts

      set_non_empty_values importer, attributes_to_import_from_facts
      importer
    end

    def set_non_empty_values importer, methods
      methods.each do |attr|
        value = importer.send(attr)
        self.send("#{attr}=", value) unless value.blank?
      end
    end

    def facts_hash
      hash = {}
      fact_values.includes(:fact_name).collect do |fact|
        hash[fact.fact_name.name] = fact.value
      end
      hash
    end

    def to_param
      name
    end

    def ==(comparison_object)
      super ||
        comparison_object.is_a?(Host::Base) &&
        id.present? &&
        comparison_object.id == id
    end

    def normalize_name
      self.name = Net::Validations.normalize_hostname(name) if self.name.present?
    end
  end
end
