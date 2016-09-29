class FactImporter
  delegate :logger, :to => :Rails
  attr_reader :counters

  def self.importer_for(type)
    importers[type.to_s] || importers[:puppet]
  end

  def self.importers
    @importers ||= { :puppet => PuppetFactImporter }.with_indifferent_access
  end

  def self.register_fact_importer(key, klass)
    importers[key.to_sym] = klass
  end

  def self.fact_features
    importers.map { |_type, importer| importer.authorized_smart_proxy_features }.compact.flatten.uniq
  end

  def self.support_background
    false
  end

  def self.authorized_smart_proxy_features
    # When writing your own Fact importer, provide feature(s) of authorized Smart Proxies
    Rails.logger.debug("Importer #{self} does not implement authorized_smart_proxy_features.")
    []
  end

  def initialize(host, facts = {})
    @error    = false
    @host     = host
    @facts    = normalize(facts)
    @counters = {}
  end

  # expect a facts hash
  def import!
    ActiveRecord::Base.transaction do
      delete_removed_facts
      update_facts
      add_new_facts
    end

    if @error
      Foreman::Logging.exception("Error during fact import for #{@host.name}", @error)
      raise ::Foreman::WrappedException.new(@error, N_("Import of facts failed for host %s"), @host.name)
    end
    logger.info("Import facts for '#{host}' completed. Added: #{counters[:added]}, Updated: #{counters[:updated]}, Deleted #{counters[:deleted]} facts")
  end

  # to be defined in children
  def fact_name_class
    raise NotImplementedError
  end

  private

  attr_reader :host, :facts

  def delete_removed_facts
    ActiveSupport::Notifications.instrument "fact_importer_deleted.foreman", :host_id => host.id, :host_name => host.name, :facts => facts, :deleted => [] do |payload|
      # deletes all facts using a single SQL query (with inner query)
      payload[:count] = @counters[:deleted] = FactValue.joins(:fact_name).where(:host => host, 'fact_names.type' => fact_name_class).where.not('fact_names.name' => facts.keys).delete_all
    end
  end

  def add_new_fact(name)
    method = host.new_record? ? :build : :create!
    fact_name = find_or_create_fact_name(name, facts[name])
    host.fact_values.send(method, :value => facts[name], :fact_name => fact_name)
  rescue => e
    logger.error("Fact #{name} could not be imported because of #{e.message}")
    @error = e
  end

  # value is used in structured importer to identify leaf nodes
  def find_or_create_fact_name(name, value = nil)
    fact_name_class.where(:name => name, :type => fact_name_class).first_or_create!
  end

  def add_new_facts
    ActiveSupport::Notifications.instrument "fact_importer_added.foreman", :host_id => host.id, :host_name => host.name, :facts => facts do |payload|
      facts_to_create = facts.keys - db_facts.pluck('fact_names.name')
      # if the host does not exists yet, we don't have an host_id to use the fact_values table.
      if facts_to_create.present?
        facts_to_create.each { |f| add_new_fact(f) }
      end
      payload[:added] = facts_to_create
      payload[:count] = @counters[:added] = facts_to_create.size
    end
  end

  def update_facts
    ActiveSupport::Notifications.instrument "fact_importer_updated.foreman", :host_id => host.id, :host_name => host.name, :facts => facts do |payload|
      time = Time.now.utc
      updated = []
      db_facts.find_each do |record|
        new_value = facts[record.name]
        if record.value != new_value
          # skip callbacks/validations
          record.update_columns(:value => new_value, :updated_at => time)
          updated << record.name
        end
      end
      payload[:updated] = updated
      payload[:count] = @counters[:updated] = updated.size
    end
  end

  def normalize(facts)
    # convert all structures to simple strings
    facts = Hash[facts.map {|k, v| [k.to_s, v.to_s]}]
    # and remove empty values
    facts.keep_if { |k, v| v.present? }
  end

  def db_facts
    host.fact_values.joins(:fact_name).where("fact_names.type = '#{fact_name_class}'")
  end
end
