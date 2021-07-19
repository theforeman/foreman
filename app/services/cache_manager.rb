class CacheManager
  def self.delete_old_permission_cache
    CachedUsergroupMember.delete_all
    CachedUserRole.delete_all
  end

  def self.create_new_permission_cache
    UsergroupMember.all.map(&:save!)
    UserRole.all.map(&:save!)
  end

  def self.create_new_filter_cache
    Role.ignore_locking do
      Filter.all.map(&:save!)
    end
  end

  def self.recache!
    Rails.logger.warn 'Recreating the whole DB cache'
    delete_old_permission_cache
    create_new_permission_cache
    create_new_filter_cache
    CacheManager.set_cache_setting(false)
  end

  def self.set_cache_setting(value)
    Setting['fix_db_cache'] = value
  end
end
