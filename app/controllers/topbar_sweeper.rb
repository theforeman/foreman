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

  def self.fragment_name(user_id = User.current.id)
    "tabs_and_title_records-#{user_id}"
  end

  def self.full_fragment_name(user_id)
    "views/#{fragment_name(user_id)}"
  end

  def self.check_user_session(user_id, session_id)
    session_key = "#{fragment_name(user_id)}-session_id"
    unless Rails.cache.fetch(session_key) == session_id
      Rails.cache.delete(full_fragment_name(User.current.id))
      Rails.cache.write(session_key, session_id)
    end
  end

  def self.expire_cache(controller)
    controller.expire_fragment(TopbarSweeper.fragment_name) if User.current
  end

  def self.expire_cache_all_users
    User.unscoped.pluck(:id).each do |user_id|
      Rails.cache.delete(full_fragment_name(user_id))
    end
  end
end
