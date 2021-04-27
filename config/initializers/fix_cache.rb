# if fix db cache flag is enabled and we are not running rake task, we want to
# recreate cache

CacheManager.recache! if !Foreman.in_rake? && Setting['fix_db_cache']
