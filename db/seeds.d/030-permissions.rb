require (Rails.root + 'db/seeds.d/020-permissions_list.rb')

PermissionsList.permissions.each do |resource, permission|
  Permission.where(:name => permission, :resource_type => resource).first_or_create
end
