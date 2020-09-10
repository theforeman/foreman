desc 'Fix user groups and authorization cache by removing all cached records and recreating them'
task :fix_db_cache => :environment do
  puts 'Recreating cache'
  if User.unscoped.find_by_login(User::ANONYMOUS_ADMIN).present?
    User.as_anonymous_admin do
      CacheManager.recache!
    end
  else
    User.without_auditing do
      CacheManager.recache!
    end
  end
end

namespace :fix_db_cache do
  task :delete_old_cache do
    User.as_anonymous_admin do
      CacheManager.delete_old_permission_cache
    end
    puts "Old cached records were deleted"
  end

  task :create_new_cache do
    User.as_anonymous_admin do
      CacheManager.create_new_permission_cache
    end
    puts "New cached records were saved"
  end

  task :cache_filter_searches do
    User.as_anonymous_admin do
      CacheManager.create_new_filter_cache
    end
    puts "Filters cache saved"
  end
end
