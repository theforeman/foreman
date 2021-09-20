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

    facts_importer = FactImporters::Structured.new(host, source_proxy, facts)
    telemetry_observe_histogram(:importer_facts_import_duration, facts.size, type: facts_importer.type)
    telemetry_duration_histogram(:importer_facts_import_duration, 1000, type: facts_importer.type) do
      facts_importer.import!
    end

    skipping_orchestration do
      host.save(:validate => false)
    end

    facts_importer.parse_facts
  end

  private

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
