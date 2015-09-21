class TopbarSweeper < ActionController::Caching::Sweeper
  observe [User, UserRole, Usergroup, Organization, Location, Filter]

  def after_create(record)
    record.expire_topbar_cache(self)
  end

  def after_update(record)
    record.expire_topbar_cache(self)
  end

  def after_destroy(record)
    record.expire_topbar_cache(self)
  end

  def after_select(record)
    record.expire_topbar_cache(self)
  end

  if Rails.env.test?
    def expire_fragment(*args)
    end
  end

  def self.fragment_name(id = User.current.id)
    "tabs_and_title_records-#{id}"
  end

  def self.expire_cache(controller)
    controller.expire_fragment(TopbarSweeper.fragment_name) if User.current
  end
end
