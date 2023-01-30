require (Rails.root + 'db/seeds.d/020-permissions_list.rb')

PermissionsList.permissions.each do |resource, permission|
  Permission.where(:name => permission, :resource_type => resource).first_or_create
end

org_admin = Role.find_by(name: 'Organization admin')
r.permissions.find_by(name: 'assign_organizations').filters.where(role_id: role).update_all(search: 'oragnization_id ^ (assigned)')
