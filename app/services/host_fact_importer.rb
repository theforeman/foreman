class HostFactImporter
  include Foreman::TelemetryHelper

  attr_reader :host

  def initialize(host)
    @host = host
  end

  def create_new_record_when_facts_are_uploaded?
    Setting[:create_new_host_when_facts_are_uploaded]
  end

  def import_facts(facts, source_proxy = nil)
    return false if !create_new_record_when_facts_are_uploaded? && host.new_record?

    # we are not importing facts for hosts in build state (e.g. waiting for a re-installation)
    raise ::Foreman::Exception.new('Host is pending for Build') if host.build?
    facts = facts.with_indifferent_access

    facts[:domain] = facts[:domain].downcase if facts[:domain].present?

    type = facts.delete(:_type)
    facts_importer = Foreman::Plugin.fact_importer_registry.get(type).new(host, facts)
    telemetry_observe_histogram(:importer_facts_import_duration, facts.size, type: type)
    telemetry_duration_histogram(:importer_facts_import_duration, 1000, type: type) do
      facts_importer.import!
    end

    skipping_orchestration do
      host.save(:validate => false)
    end

    parse_facts(facts, type, source_proxy)
  end

  def parse_facts(facts, type, source_proxy)
    time = facts[:_timestamp]
    time = time.to_time if time.is_a?(String)
    host.last_compile = time if time

    # taxonomy must be set before populate_fields_from_facts call
    set_host_taxonomies(facts)

    skipping_orchestration do
      unless host.build?
        parser = Foreman::Plugin.fact_parser_registry[type].new(facts)

        telemetry_duration_histogram(:importer_facts_import_duration, 1000, type: type) do
          host.populate_fields_from_facts(parser, type, source_proxy)
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

  private

  def set_host_taxonomies(facts)
    ['location', 'organization'].each do |taxonomy|
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
end
