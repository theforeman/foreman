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

  private
  def expire_cache_for(record)
    expire_fragment("tabs_and_title_records-#{User.current.id}") if User.current
  end
end
