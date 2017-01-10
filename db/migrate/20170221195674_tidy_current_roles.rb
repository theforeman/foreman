require Rails.root + 'db/seeds.d/02-roles_list.rb'

class TidyCurrentRoles < ActiveRecord::Migration
  def up
    # if there are no roles, then this is a new installation and we will create them in seeds
    return if Role.count == 0
    Filter.reset_column_information
    Role.without_auditing do
      ::RolesList.seeded_roles.each do |name, permission_names|
        role = Role.find_by :name => name
        if role
          process_existing name, role, permission_names
        else
          create_from_seeds name, permission_names
        end
      end
    end
    process_default_role
  end

  def process_existing(original_name, role, permission_names)
    diff = role.permission_diff permission_names
    return if diff.empty?
    rename_existing role, original_name
    create_from_seeds original_name, permission_names
  end

  def rename_existing(role, original_name)
    prefix = "Customized"
    role_name = "#{prefix} #{original_name}"
    if Role.find_by(:name => role_name)
      rename_with_free_name role, prefix, original_name
    else
      role.update_attribute :name, role_name
    end
  end

  def rename_with_free_name(role, prefix, original_name)
    num = 1
    new_name = generate_name prefix, original_name, num
    while Role.find_by :name => new_name
      new_name = generate_name prefix, original_name, num
      num += 1
    end
    role.update_attribute :name, new_name
  end

  def generate_name(prefix, original_name, num)
    "#{prefix} #{original_name} #{num}"
  end

  def create_from_seeds(name, permission_names)
    SeedHelper.create_role name, permission_names, 0, false
  end

  def process_default_role
    Role.default.update_attribute :origin, "foreman"
  end
end
