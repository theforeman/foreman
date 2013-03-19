require 'facts_importer'

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

    include Hostext::Search

    def self.attributes_protected_by_default
      super - [ inheritance_column ]
    end

    def self.importHostAndFacts yaml
    end

    # import host facts, required when running without storeconfigs.
    # expect a Puppet::Node::Facts
    def importFacts name, facts

      # we are not importing facts for hosts in build state (e.g. waiting for a re-installation)
      raise "Host is pending for Build" if build
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
      db_facts = {}

      deletions = []
      fact_values.includes(:fact_name).each do |value|
        deletions << value['id'] and next unless facts.include?(value['name'])
        # Now store them for later testing.
        db_facts[value['name']] ||= []
        db_facts[value['name']] << value
      end

      # Now get rid of any parameters whose value list is different.
      # This might be extra work in cases where an array has added or lost
      # a single value, but in the most common case (a single value has changed)
      # this makes sense.
      db_facts.each do |name, value_hashes|
        values = value_hashes.collect { |v| v['value'] }

        unless values == facts[name]
          value_hashes.each { |v| deletions << v['id'] }
        end
      end

      # Perform our deletions.
      FactValue.delete(deletions) unless deletions.empty?

      # Get FactNames in one call
      fact_names = FactName.where(:name => facts.keys)

      # Create any needed new FactNames
      facts.keys.dup.delete_if { |n| fact_names.map(&:name).include? n }.each do |needed|
        fact_names << FactName.create(:name => needed)
      end

      # Lastly, add any new parameters.
      fact_names.each do |fact_name|
        next if db_facts.include?(fact_name.name)
        value = facts[fact_name.name]
        values = value.is_a?(Array) ? value : [value]
        values.each do |v|
          next if v.nil?
          fact_values.build(:value => v, :fact_name => fact_name)
        end
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
      errors.add(:name, "must be downcase") unless name == name.downcase
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
