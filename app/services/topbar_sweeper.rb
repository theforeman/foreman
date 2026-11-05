class TopbarSweeper
  THREAD_KEY = :topbar_sweeper_controller

  class << self
    def controller
      Thread.current[THREAD_KEY]
    end

    def controller=(ctrl)
      Thread.current[THREAD_KEY] = ctrl
    end

    def expire_cache(user = User.current)
      controller&.expire_fragment(fragment_name(user.id)) if user.present?
    end

    def fragment_name(id = User.current.id)
      "tabs_and_title_records-#{id}"
    end

    def expire_cache_all_users
      User.unscoped.pluck(:id).each do |id|
        Rails.cache.delete("views/#{fragment_name(id)}")
      end
    end
  end
end
