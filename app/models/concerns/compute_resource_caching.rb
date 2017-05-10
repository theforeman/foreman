module ComputeResourceCaching
  extend ActiveSupport::Concern

  included do
    after_update :refresh_cache_ignoring_errors, :if => proc { |cr| cr.caching_enabled? }
  end

  def refresh_cache_ignoring_errors
    refresh_cache
    true
  end

  def refresh_cache
    cache.refresh
  end

  private

  def cache
    @cache ||= ComputeResourceCache.new(self)
  end
end
