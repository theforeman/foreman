# if fix db cache flag is enabled and we are not running rake task, we want to
# recreate cache

if (Setting.table_exists? rescue(false))
  flag = Setting::General.find_or_initialize_by_name('fix_db_cache',
                                                     :description   => 'Fix DB cache on next Foreman restart',
                                                     :settings_type => 'boolean', :default => false)
end

if File.basename($0) != "rake" && flag.value
  CacheManager.recache!
end
