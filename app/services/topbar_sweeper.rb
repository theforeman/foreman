class TopbarSweeper
  include Singleton
  attr_accessor :controller

  def expire_cache(user = User.current)
    controller.expire_fragment(self.class.fragment_name(user.id)) if controller.present? && user.present?
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
