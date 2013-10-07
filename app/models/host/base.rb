require 'facts_importer'

module Host
  class Base < ActiveRecord::Base
    include Foreman::STI
    self.table_name = :hosts
    OWNER_TYPES = %w(User Usergroup)

    belongs_to :model
    has_many :fact_values, :dependent => :destroy, :foreign_key => :host_id
    has_many :fact_names, :through => :fact_values

    alias_attribute :hostname, :name
    validates_presence_of   :name
    validates_uniqueness_of :name
    validate :is_name_downcased?
    validates_inclusion_of :owner_type,
                           :in          => OWNER_TYPES,
                           :allow_blank => true,
                           :message     => (_("Owner type needs to be one of the following: %s") % OWNER_TYPES.join(', '))

    scope :my_hosts, lambda {
      user                 = User.current
      return { :conditions => "" } if user.admin? # Admin can see all hosts

      owner_conditions             = sanitize_sql_for_conditions(["((hosts.owner_id in (?) AND hosts.owner_type = 'Usergroup') OR (hosts.owner_id = ? AND hosts.owner_type = 'User'))", user.my_usergroups.map(&:id), user.id])
      domain_conditions            = sanitize_sql_for_conditions([" (hosts.domain_id in (?))",dms = (user.domain_ids)])
      compute_resource_conditions  = sanitize_sql_for_conditions([" (hosts.compute_resource_id in (?))",(crs = user.compute_resource_ids)])
      hostgroup_conditions         = sanitize_sql_for_conditions([" (hosts.hostgroup_id in (?))",(hgs = user.hostgroup_ids)])
      organization_conditions      = sanitize_sql_for_conditions([" (hosts.organization_id in (?))",orgs = (user.organization_ids)])
      location_conditions          = sanitize_sql_for_conditions([" (hosts.location_id in (?))",locs = (user.location_ids)])

      fact_conditions = ""
      for user_fact in (ufs = user.user_facts)
        fact_conditions += sanitize_sql_for_conditions ["(hosts.id = fact_values.host_id and fact_values.fact_name_id = ? and fact_values.value #{user_fact.operator} ?)", user_fact.fact_name_id, user_fact.criteria]
        fact_conditions = user_fact.andor == "and" ? "(#{fact_conditions}) and " : "#{fact_conditions} or  "
      end
      if (match = fact_conditions.match(/^(.*).....$/))
        fact_conditions = "(#{match[1]})"
      end

      conditions = ""
      if user.filtering?
        conditions  = "#{owner_conditions}"                                                                                                                                 if     user.filter_on_owner
        (conditions = (user.domains_andor           == "and") ? "(#{conditions}) and #{domain_conditions} "           : "#{conditions} or #{domain_conditions} ")           unless dms.empty?
        (conditions = (user.compute_resources_andor == "and") ? "(#{conditions}) and #{compute_resource_conditions} " : "#{conditions} or #{compute_resource_conditions} ") unless crs.empty?
        (conditions = (user.hostgroups_andor        == "and") ? "(#{conditions}) and #{hostgroup_conditions} "        : "#{conditions} or #{hostgroup_conditions} ")        unless hgs.empty?
        (conditions = (user.facts_andor             == "and") ? "(#{conditions}) and #{fact_conditions} "             : "#{conditions} or #{fact_conditions} ")             unless ufs.empty?
        (conditions = (user.organizations_andor     == "and") ? "(#{conditions}) and #{organization_conditions} "     : "#{conditions} or #{organization_conditions} ")     unless orgs.empty?
        (conditions = (user.locations_andor         == "and") ? "(#{conditions}) and #{location_conditions} "         : "#{conditions} or #{location_conditions} ")         unless locs.empty?
        conditions.sub!(/\s*\(\)\s*/, "")
        conditions.sub!(/^(?:\(\))?\s?(?:and|or)\s*/, "")
        conditions.sub!(/\(\s*(?:or|and)\s*\(/, "((")
      end

      { :joins => ufs.empty? ? nil : :fact_values,
        :conditions => conditions }
    }
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
      raise ::Foreman::Exception.new("Host is pending for Build") if build

      # Ensure timestamp is always a string
      if facts.include?(:_timestamp)
        timestamp = facts.delete(:_timestamp)
        facts['_timestamp'] = timestamp unless facts['_timestamp'].present?
      end
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
    end

    # Inspired from Puppet::Rails:Host
    def merge_facts(facts)
      db_facts = {}

      deletions = []
      fact_values.includes(:fact_name).each do |value|
        deletions << value['id'] and next unless facts.include?(value.name)
        # Now store them for later testing.
        db_facts[value.name] ||= []
        db_facts[value.name] << value
      end

      # Now get rid of any parameters whose value list is different.
      # This might be extra work in cases where an array has added or lost
      # a single value, but in the most common case (a single value has changed)
      # this makes sense.
      db_facts.each do |name, value_hashes|
        db_values = value_hashes.collect { |v| v['value'] }
        value = facts[name]
        values = value.is_a?(Array) ? value : [value.to_s]

        unless db_values == values
          value_hashes.each { |v| deletions << v['id'] }
        end
      end

      FactValue.delete(deletions) unless deletions.empty?

      # Get FactNames in one call
      fact_names = FactName.maximum(:id, :group => 'name')

      # Create any needed new FactNames
      facts.each do |name, value|
        next if db_facts.include?(name)
        values = value.is_a?(Array) ? value : [value]

        values.each do |v|
          next if v.nil?
          fact_values.build(:value => v,
                            :fact_name_id => fact_names[name] || FactName.create!(:name => name).id)
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

    def ==(comparison_object)
      super ||
        comparison_object.is_a?(Host::Base) &&
        id.present? &&
        comparison_object.id == id
    end

  end
end
