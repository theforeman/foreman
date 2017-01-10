require (Rails.root + 'db/seeds.d/02-roles_list.rb')

Role.without_auditing do
  RolesList.seeded_roles.each do |role_name, permission_names|
    SeedHelper.create_role(role_name, permission_names, 0)
  end
  RolesList.default_role.each do |role_name, permission_names|
    SeedHelper.create_role(role_name, permission_names, Role::BUILTIN_DEFAULT_ROLE)
  end
end
