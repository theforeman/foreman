class FactImporter
  delegate :logger, :to => :Rails
  attr_reader :counters

  def self.importer_for(type)
    importers[type.to_s]
  end

  def self.importers
    @importers ||= {}.with_indifferent_access
  end

  def self.register_fact_importer(key, klass, default = false)
    importers.default = klass if default

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
    # This function uses its own transactions that should not be included
    # in the transaction that handles fact values
    ensure_fact_names

    ActiveRecord::Base.transaction do
      delete_removed_facts
      update_facts
      add_new_facts
    end

    report_error(@error) if @error
    logger.info("Import facts for '#{host}' completed. Added: #{counters[:added]}, Updated: #{counters[:updated]}, Deleted #{counters[:deleted]} facts")
  end

  def report_error(error)
    Foreman::Logging.exception("Error during fact import for #{@host.name}", error)
    raise ::Foreman::WrappedException.new(error, N_("Import of facts failed for host %s"), @host.name)
  end

  # to be defined in children
  def fact_name_class
    raise NotImplementedError
  end

  private

  attr_reader :host, :facts, :fact_names, :fact_names_by_id

  def fact_name_class_name
    @fact_name_class_name ||= fact_name_class.name
  end

  def ensure_fact_names
    initialize_fact_names

    missing_keys = facts.keys - fact_names.keys
    add_missing_fact_names(missing_keys)
  end

  def add_missing_fact_names(missing_keys)
    missing_keys.sort.each do |fact_name|
      # create a new record and make sure it could be saved.
      name_record = fact_name_class.new(fact_name_attributes(fact_name))

      ensure_no_active_transaction

      ActiveRecord::Base.transaction(:requires_new => true) do
        begin
          save_name_record(name_record)
        rescue ActiveRecord::RecordNotUnique
          name_record = nil
        end
      end

      # if the record could not be saved in the previous transaction,
      # re-get the record outside of transaction
      if name_record.nil?
        name_record = fact_name_class.find_by!(name: fact_name)
      end

      # make the new record available immediately for other fact_name_attributes calls
      @fact_names[fact_name] = name_record
    end
  end

  def initialize_fact_names
    name_records = fact_name_class.unscoped.where(:name => facts.keys, :type => fact_name_class_name)
    @fact_names = {}
    @fact_names_by_id = {}
    name_records.find_each do |record|
      @fact_names[record.name] = record
      @fact_names_by_id[record.id] = record
    end
  end

  def fact_name_attributes(fact_name)
    {
      name: fact_name
    }
  end

  def delete_removed_facts
    ActiveSupport::Notifications.instrument "fact_importer_deleted.foreman", :host_id => host.id, :host_name => host.name, :facts => facts, :deleted => [] do |payload|
      delete_query = FactValue.joins(:fact_name).where(:host => host, 'fact_names.type' => fact_name_class_name).where.not(:fact_name => fact_names.values)
      if ActiveRecord::Base.connection.adapter_name.downcase.starts_with? 'mysql'
        # MySQL does not handle delete with inner query correctly (slow) so we will do two queries on purpose
        payload[:count] = @counters[:deleted] = FactValue.where(:id => delete_query.pluck(:id)).delete_all
      else
        # deletes all facts using a single SQL query with inner query otherwise
        payload[:count] = @counters[:deleted] = delete_query.delete_all
      end
    end
  end

  def add_new_fact(name)
    # if the host does not exist yet, we don't have an host_id to use the fact_values table.
    method = host.new_record? ? :build : :create!
    fact_name = fact_names[name]
    host.fact_values.send(method, :value => facts[name], :fact_name => fact_name)
  rescue => e
    logger.error("Fact #{name} could not be imported because of #{e.message}")
    @error = e
  end

  def add_new_facts
    ActiveSupport::Notifications.instrument "fact_importer_added.foreman", :host_id => host.id, :host_name => host.name, :facts => facts do |payload|
      facts_to_create = facts.keys - db_facts.pluck(:fact_name_id).map { |name_id| fact_names_by_id[name_id].name }
      facts_to_create.each { |f| add_new_fact(f) }
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
    host.fact_values.where(:fact_name => fact_names.values)
  end

  def ensure_no_active_transaction
    raise 'Fact names should be added outside of global transaction' if ActiveRecord::Base.connection.transaction_open?
  end

  def save_name_record(name_record)
    name_record.save!(:validate => false)
  end
end
