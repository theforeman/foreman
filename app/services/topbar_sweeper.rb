class TopbarSweeper
  include Singleton
  attr_accessor :controller

  def expire_cache(user = User.current)
    if controller.present? && user.present?
      controller.expire_fragment(self.class.fragment_name(user.id))
      expire_count_cache(user)
    end
  end

  def expire_count_cache(user)
    Rails.cache.delete("hosts_count/#{controller.resource_name}/#{user.id}")
  end

  class << self
    delegate :expire_cache, to: :instance

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
