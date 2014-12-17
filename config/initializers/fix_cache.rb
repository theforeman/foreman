# if fix db cache flag is enabled and we are not running rake task, we want to
# recreate cache

if (Setting.table_exists? rescue(false))
  fix_db_cache = Setting::General.find_or_initialize_by(:name => 'fix_db_cache',
                                                     :description   => 'Fix DB cache on next Foreman restart',
                                                     :settings_type => 'boolean', :default => false)

  CacheManager.recache! if !Foreman.in_rake? && fix_db_cache.value
end
