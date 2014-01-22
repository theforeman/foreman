desc 'Fix user groups and authorization cache by removing all cached records and recreating them'
task :fix_db_cache => :environment do
  puts 'Recreating cache'
  CacheManager.recache!
end

namespace :fix_db_cache do
  task :delete_old_cache do
    CacheManager.delete_old_permission_cache
    puts "Old cached records were deleted"
  end

  task :create_new_cache do
    CacheManager.create_new_permission_cache
    puts "New cached records were saved"
  end

  task :cache_filter_searches do
    CacheManager.create_new_filter_cache
    puts "Filters cache saved"
  end
end
