# if fix db cache flag is enabled and we are not running rake task, we want to
# recreate cache
if File.basename($0) != "rake" && Setting::General[:fix_db_cache]
  CacheManager.recache!
end
