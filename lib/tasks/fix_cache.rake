desc 'Fix user groups and authorization cache by removing all cached records and recreating them'
task :fix_db_cache do
  CachedUsergroupMember.delete_all
  CachedUserRole.delete_all
  puts "Old cached records were deleted"

  UsergroupMember.all.map &:save!
  UserRole.all.map &:save!
  puts "New cached records were saved"
end
