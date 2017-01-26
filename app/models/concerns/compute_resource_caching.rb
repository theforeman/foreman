module ComputeResourceCaching
  extend ActiveSupport::Concern

  def refresh_cache
    cache.refresh
  end

  private

  def cache
    @cache ||= ComputeResourceCache.new(self)
  end
end
