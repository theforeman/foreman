class HostFactImporter
  include Foreman::TelemetryHelper

  attr_reader :host

  def initialize(host)
    @host = host
  end

  def create_new_record_when_facts_are_uploaded?
    Setting[:create_new_host_when_facts_are_uploaded]
  end

  def skip_orchestration?
    !SETTINGS[:enable_orchestration_on_fact_import]
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

    skiping_orchestration do
      host.save(:validate => false)
    end

    parse_facts(facts, type, source_proxy)
  end

  def parse_facts(facts, type, source_proxy)
    skiping_orchestration do
      host.parse_facts facts, type, source_proxy
    end
  end

  private

  def skiping_orchestration(&block)
    if host.is_a?(Host::Managed)
      host.without_orchestration_if(skip_orchestration?, &block)
    else
      yield
    end
  end
end
