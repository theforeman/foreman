module TopbarCacheExpiry
  extend ActiveSupport::Concern

  included do
    after_create :expire_topbar_cache_within_controller
    after_update :expire_topbar_cache_within_controller
    after_destroy :expire_topbar_cache_within_controller
  end

  def expire_topbar_cache_within_controller
    expire_topbar_cache if TopbarSweeper.instance.controller.present?
  end
end
