class TopbarSweeper < ActionController::Caching::Sweeper
  observe [User, UserRole, Organization, Location]

  def after_create(record)
    expire_cache_for(record)
  end

  def after_update(record)
    expire_cache_for(record)
  end

  def after_destroy(record)
    expire_cache_for(record)
  end

  def after_select(record)
    expire_cache_for(record)
  end

  def self.fragment_name
    "tabs_and_title_records-#{User.current.id}"
  end

  def self.expire_cache(controller)
    controller.expire_fragment(TopbarSweeper.fragment_name) if User.current
  end

  private
  def expire_cache_for(record)
    expire_fragment(TopbarSweeper.fragment_name) if User.current
  end
end
