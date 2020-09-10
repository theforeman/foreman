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
    flag = Setting::General.find_by_name('fix_db_cache')
    # we call this from places where setting does not have to exist, in that case we create new record here
    flag ||= Setting::General.new(:name => 'fix_db_cache',
                                  :description   => 'Fix DB cache on next Foreman restart',
                                  :settings_type => 'boolean')

    # we need to call default= and value= explicitly so it stores value in YAML
    flag.default = false
    flag.value = value
    flag.save
  end
end
