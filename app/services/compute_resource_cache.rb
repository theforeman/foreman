# This class caches attributes for a compute resource in
# rails cache to speed up slow or expensive API calls
class ComputeResourceCache
  attr_accessor :compute_resource, :cache_duration

  delegate :logger, :to => ::Rails

  def initialize(compute_resource, cache_duration: 180.minutes)
    self.compute_resource = compute_resource
    self.cache_duration = cache_duration
  end

  # Tries to retrieve the value for a given key from the cache
  # and returns the retrieved value. If the cache is empty,
  # the given block is executed and the block's return stored
  # in the cache. This value is then returned by this method.
  def cache(key, &block)
    return get_uncached_value(key, &block) unless cache_enabled?
    cached_value = read(key)
    return cached_value if cached_value
    return unless block_given?
    uncached_value = get_uncached_value(key, &block)
    write(key, uncached_value)
    uncached_value
  end

  def delete(key)
    logger.debug "Deleting from compute resource cache: #{key}"
    Rails.cache.delete(cache_key + key.to_s)
  end

  def read(key)
    logger.debug "Reading from compute resource cache: #{key}"
    Rails.cache.read(cache_key + key.to_s, cache_options)
  end

  def write(key, value)
    logger.debug "Storing in compute resource cache: #{key}"
    Rails.cache.write(cache_key + key.to_s, value, cache_options)
  end

  def refresh
    # Rolls the cache_scope to refresh the cache as not all
    # cache implementations (eg. memcached) support deleting
    # keys by a regex
    Rails.cache.delete(cache_scope_key)
    true
  rescue StandardError => e
    Foreman::Logging.exception('Failed to refresh a compute resource cache', e)
    false
  end

  def cache_scope
    Rails.cache.fetch(cache_scope_key, cache_options) do
      Foreman.uuid
    end
  end

  def cache_enabled?
    compute_resource.persisted? && compute_resource.caching_enabled
  end

  private

  def get_uncached_value(key, &block)
    return unless block_given?
    start_time = Time.now.utc
    result = compute_resource.instance_eval(&block)
    end_time = Time.now.utc
    duration = end_time - start_time.round(4)
    logger.info("Loaded compute resource data for #{key} in #{duration} seconds")
    result
  end

  def cache_key
    "compute_resource_#{compute_resource.id}-#{cache_scope}/"
  end

  def cache_scope_key
    "compute_resource_#{compute_resource.id}-cache_scope_key"
  end

  def cache_options
    {
      :expires_in => cache_duration,
      :race_condition_ttl => 1.minute,
    }
  end
end
