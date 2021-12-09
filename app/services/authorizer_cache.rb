module AuthorizerCache
  include Foreman::TelemetryHelper

  def initialize_cache
    @cache = {}
  end

  def collection_cache_lookup(subject, permission)
    collection = @cache[cache_key(subject, permission)] || fetch_collection(subject, permission)

    collection.include?(subject.id)
  end

  private

  def fetch_collection(subject, permission)
    collection = @cache[cache_key(subject, permission)] = find_collection(subject.class, :permission => permission).pluck(:id)
    telemetry_increment_counter(:authorizer_cache_records_fetched, collection.count, class: subject&.class || :Other)
    Rails.logger.info("Loaded #{collection.size} #{subject.class} records into authorization cache for permission #{permission}, consider skipping caching for this check.") if collection.size > 100000
    collection
  end

  def cache_key(subject, permission)
    "#{subject.class}/#{permission}"
  end
end
