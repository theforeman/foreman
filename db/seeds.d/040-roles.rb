require Rails.root + 'db/seeds.d/020-roles_list.rb'

Role.without_auditing do
  Filter.without_auditing do
    Role.skip_permission_check do
      RolesList.seeded_roles.each do |role_name, options|
        SeedHelper.create_role(role_name, options, 0)
      end
      RolesList.default_role.each do |role_name, options|
        SeedHelper.create_role(role_name, options, Role::BUILTIN_DEFAULT_ROLE)
      end
    end
  end
end
