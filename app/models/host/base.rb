require 'facts_importer'
require 'set'

module Host
  class Base < ActiveRecord::Base
    include Foreman::STI
    self.table_name = :hosts

    belongs_to :model
    has_many :fact_values, :dependent => :destroy, :foreign_key => :host_id
    has_many :fact_names, :through => :fact_values

    alias_attribute :hostname, :name
    validates_presence_of   :name
    validates_uniqueness_of :name
    validate :is_name_downcased?

    def self.attributes_protected_by_default
      super - [ inheritance_column ]
    end

    def self.importHostAndFacts yaml
    end

    # import host facts, required when running without storeconfigs.
    # expect a Puppet::Node::Facts
    def importFacts name, facts

      # we are not importing facts for hosts in build state (e.g. waiting for a re-installation)
      raise ::Foreman::Exception.new(N_("Host is pending for Build")) if build
      time = facts[:_timestamp]
      time = time.to_time if time.is_a?(String)

      # we are not doing anything we already processed this fact (or a newer one)
      if time
        return true unless last_compile.nil? or (last_compile + 1.minute < time)
        self.last_compile = time
      end
      # save all other facts
      merge_facts(facts)
      save(:validate => false)

      populateFieldsFromFacts(facts)

      # we are saving here with no validations, as we want this process to be as fast
      # as possible, assuming we already have all the right settings in Foreman.
      # If we don't (e.g. we never install the server via Foreman, we populate the fields from facts
      # TODO: if it was installed by Foreman and there is a mismatch,
      # we should probably send out an alert.
      return self.save(:validate => false)

    rescue Exception => e
      logger.warn "Failed to save #{name}: #{e}"
    end

    # Inspired from Puppet::Rails:Host
    def merge_facts(facts)
      normalized_facts = normalize_facts(facts)

      FactValue.delete_all([
          "fact_name_id in (select id from fact_names where name not in (?)) and host_id=?",
          normalized_facts.keys, id
      ])

      # Now get rid of any parameters whose value list is different.
      # This might be extra work in cases where an array has added or lost
      # a single value, but in the most common case (a single value has changed)
      # this makes sense.
      db_facts = fact_values.includes(:fact_name).inject({}) do |hash, value|
        hash.update(value.name => [value]) {|key, oldval, newval| oldval << newval.first}
      end
      deletions = db_facts.inject([]) do |to_delete, db_fact|
        name, values = *db_fact
        (Set.new(values.collect(&:value)) <=> Set.new(normalized_facts[name])) == 0 ?
          to_delete :
          (to_delete << values.collect(&:id)).flatten
      end
      FactValue.delete(deletions) unless deletions.empty?

      fact_names = FactName.maximum(:id, :group => 'name')
      db_facts = fact_values.includes(:fact_name).index_by(&:name)

      normalized_facts.each do |name, values|
        next if db_facts.include?(name)
        fact_name_id = fact_names[name] || FactName.create!(:name => name).id
        fact_values.build(values.collect { |v| {:value => v, :fact_name_id => fact_name_id} })
      end
    end

    def normalize_facts(facts)
      facts.inject({}) do |hash, fact|
         name, values = *fact

         values = values.is_a?(Array) ? values : [values]
         values = values.reject { |v| v.nil? }.collect { |v| v.to_s }

         values.empty? ? hash : hash.update(name.to_s => values)
      end
    end

    def attributes_to_import_from_facts
      attrs = [:model]
    end

    def populateFieldsFromFacts facts = self.facts_hash
      # we don't import facts for host in build mode
      return if build?

      importer = Facts::Importer.new facts

      set_non_empty_values importer, attributes_to_import_from_facts
      importer
    end

    def set_non_empty_values importer, methods
      methods.each do |attr|
        value = importer.send(attr)
        self.send("#{attr}=", value) unless value.blank?
      end
    end

    def is_name_downcased?
      return unless name.present?
      errors.add(:name, _("must be lowercase")) unless name == name.downcase
    end

    def facts_hash
      hash = {}
      fact_values.all(:include => :fact_name).collect do |fact|
        hash[fact.fact_name.name] = fact.value
      end
      hash
    end

    def to_param
      name
    end

  end
end
