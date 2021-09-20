module FactImporters
  class Base
    include Foreman::TelemetryHelper

    delegate :logger, :to => :Rails
    attr_reader :counters
    attr_reader :type

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
          :prefix => '(\A|.*::|\A(facter_)?(mtu|macaddress|(ipaddress|network|netmask)6?)_)',
          :suffix => '(\Z|::.*)',
        }
      )
    end

    def initialize(host, source_proxy, facts = {})
      facts = facts.with_indifferent_access
      facts[:domain] = facts[:domain].downcase if facts[:domain].present?

      @type = facts.delete(:_type)
      @time = facts[:_timestamp]
      fact_parser = Foreman::Plugin.fact_parser_registry[@type]
      facts = facts[fact_parser.facts_key] if fact_parser.respond_to?(:facts_key) && fact_parser.facts_key

      @error    = false
      @facts    = normalizer.new(facts, excluded_facts).normalize
      @parser   = fact_parser.new(facts)
      @host     = @parser.host_from_facts || host
      @counters = {}
      @proxy    = source_proxy
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

    def parse_facts
      time = Time.zone.local(@time) if time.is_a?(String)
      host.last_compile = time if time

      # taxonomy must be set before populate_fields_from_facts call
      set_host_taxonomies(facts)

      skipping_orchestration do
        unless host.build?
          telemetry_duration_histogram(:importer_facts_import_duration, 1000, type: type) do
            host.populate_fields_from_facts(@parser, @type, @proxy)
          end
        end

        # we are saving here with no validations, as we want this process to be as fast
        # as possible, assuming we already have all the right settings in Foreman.
        # If we don't (e.g. we never install the server via Foreman, we populate the fields from facts
        # TODO: if it was installed by Foreman and there is a mismatch,
        # we should probably send out an alert.
        host.save(:validate => false)
      end
    end

    def report_error(error)
      Foreman::Logging.exception("Error during fact import for #{@host.name}", error)
      raise ::Foreman::WrappedException.new(error, N_("Import of facts failed for host %s"), @host.name)
    end

    # to be defined in children
    def fact_name_class
      @parser.fact_name_class
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
      db_facts = host.fact_values.joins(:fact_name).where(fact_names: {type: fact_name_class_name}).reorder(nil).pluck(:name, :value, :id)
      db_facts.each do |name, value, id|
        next unless fact_names.include?(name)
        new_value = facts[name]
        if value != new_value
          # skip callbacks/validations
          FactValue.where(id: id).update_all(:value => new_value, :updated_at => time)
          updated += 1
        end
      end
      db_facts_names = db_facts.map(&:first) & fact_names.keys
      @facts_to_create = facts.keys - db_facts_names
      @counters[:updated] = updated
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

    def set_host_taxonomies(facts)
      %w(location organization).each do |taxonomy|
        taxonomy_class = taxonomy.classify.constantize
        taxonomy_fact = Setting["#{taxonomy}_fact"]

        if taxonomy_fact.present? && facts.key?(taxonomy_fact)
          taxonomy_from_fact = taxonomy_class.find_by_title(facts[taxonomy_fact].to_s)
        else
          default_taxonomy = taxonomy_class.find_by_title(Setting["default_#{taxonomy}"])
        end

        if host.send(taxonomy).present?
          # Change taxonomy to fact taxonomy if set, otherwise leave it as is
          host.send("#{taxonomy}=", taxonomy_from_fact) unless taxonomy_from_fact.nil?
        else
          # No taxonomy was set, set to fact taxonomy or default taxonomy
          host.send("#{taxonomy}=", (taxonomy_from_fact || default_taxonomy))
        end
        taxonomy_class.current = host.send(taxonomy)
      end
    end

    def skipping_orchestration
      if host.is_a?(Host::Managed)
        host.without_orchestration do
          yield
        end
      else
        yield
      end
    end

    def excluded_facts
      @excluded_facts ||= Base.excluded_facts_regex
    end

    def normalizer
      Normalizers::Base
    end
  end
end
