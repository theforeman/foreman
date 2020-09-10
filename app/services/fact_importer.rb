class FactImporter
  include Foreman::TelemetryHelper

  delegate :logger, :to => :Rails
  attr_reader :counters

  def self.importer_for(type)
    Foreman::Deprecation.deprecation_warning('2.2', 'Use FactImporterRegistry#get or Foreman::Plugin.importer_registry.get methods instead of FactImporter.importer_for')
    Foreman::Plugin.fact_importer_registry.get(type)
  end

  def self.importers
    Foreman::Deprecation.deprecation_warning('2.2', 'Use FactImporterRegistry#importers or Foreman::Plugin.importer_registry.importers method instead of FactImporter.importers')
    Foreman::Plugin.fact_importer_registry.importers
  end

  def self.register_fact_importer(key, klass, default = false)
    Foreman::Deprecation.deprecation_warning('2.2', 'Use FactImporterRegistry#register or Foreman::Plugin.importer_registry.register method instead of FactImporter.register_fact_importer')
    Foreman::Plugin.fact_importer_registry.register(key, klass, default)
  end

  def self.fact_features
    Foreman::Deprecation.deprecation_warning('2.2', 'Use FactImporterRegistry#fact_features or Foreman::Plugin.importer_registry.fact_features method instead of FactImporter.fact_features')
    Foreman::Plugin.fact_importer_registry.fact_features
  end

  def self.support_background
    false
  end

  def self.authorized_smart_proxy_features
    # When writing your own Fact importer, provide feature(s) of authorized Smart Proxies
    Rails.logger.debug("Importer #{self} does not implement authorized_smart_proxy_features.")
    []
  end

  def self.excluded_facts_regex
    Setting.convert_array_to_regexp(
      Setting[:excluded_facts],
      {
        :prefix => '(\A|.*::|.*_)',
        :suffix => '(\Z|::.*)',
      }
    )
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
    telemetry_increment_counter(:importer_facts_count_processed, counters[:added], type: fact_name_class_humanized, action: :added)
    telemetry_increment_counter(:importer_facts_count_processed, counters[:updated], type: fact_name_class_humanized, action: :updated)
    telemetry_increment_counter(:importer_facts_count_processed, counters[:deleted], type: fact_name_class_humanized, action: :deleted)
  end

  def report_error(error)
    Foreman::Logging.exception("Error during fact import for #{@host.name}", error)
    raise ::Foreman::WrappedException.new(error, N_("Import of facts failed for host %s"), @host.name)
  end

  # to be defined in children
  def fact_name_class
    raise NotImplementedError
  end

  def fact_name_class_humanized
    @class_humanized ||= fact_name_class.name.demodulize.underscore
  end

  private

  attr_reader :host, :facts, :fact_names, :facts_to_create

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
        save_name_record(name_record)
      rescue ActiveRecord::RecordNotUnique
        name_record = nil
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
    name_records = fact_name_class.unscoped.where(:name => facts.keys, :type => fact_name_class_name).reorder('')
    @fact_names = name_records.index_by(&:name)
  end

  def fact_name_attributes(fact_name)
    {
      name: fact_name,
    }
  end

  def delete_removed_facts
    delete_query = FactValue.joins(:fact_name).where(:host => host, 'fact_names.type' => fact_name_class_name).where.not(:fact_name => fact_names.values).reorder('')
    @counters[:deleted] = delete_query.delete_all
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
    facts_to_create.each { |f| add_new_fact(f) }
    @counters[:added] = facts_to_create.size
  end

  def update_facts
    time = Time.now.utc
    updated = 0
    db_facts_names = []
    host.fact_values.joins(:fact_name).where('fact_names.type' => fact_name_class_name).reorder('').find_each do |record|
      next unless fact_names.include?(record.name)
      new_value = facts[record.name]
      if record.value != new_value
        # skip callbacks/validations
        record.update_columns(:value => new_value, :updated_at => time)
        updated += 1
      end
      db_facts_names << record.name
    end
    @facts_to_create = facts.keys - db_facts_names
    @counters[:updated] = updated
  end

  def normalize(facts)
    normalized_facts = {}
    facts.each do |k, v|
      key = k.to_s
      val = v.to_s

      normalized_facts[key] = val unless val.empty? || key.match(excluded_facts)
    end
    normalized_facts
  end

  def ensure_no_active_transaction
    message = 'Fact names should be added outside of global transaction.'
    if Rails.env.test?
      message += <<-TEST_ERROR
        You are updating facts from a test, you can use allow_transactions_for or
        allow_transactions_for_any_importer from fact_importer_test_helper.rb if you
        wish to continue with facts upload. Please be aware that fact uploading in tests
        could not run in parallel.
      TEST_ERROR
    end
    raise message if ActiveRecord::Base.connection.transaction_open?
  end

  def save_name_record(name_record)
    name_record.save!(:validate => false)
  end

  def excluded_facts
    @excluded_facts ||= FactImporter.excluded_facts_regex
  end
end
