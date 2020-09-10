require Rails.root + 'db/seeds.d/020-roles_list.rb'

class TidyCurrentRoles < ActiveRecord::Migration[4.2]
  def up
    # if there are no roles, then this is a new installation and we will create them in seeds
    return if Role.count == 0
    Filter.reset_column_information
    Role.without_auditing do
      ::RolesList.seeded_roles.each do |name, options|
        role = Role.find_by :name => name
        if role
          process_existing name, role, options
        else
          create_from_seeds name, options
        end
      end
    end
    process_default_role
  end

  def process_existing(original_name, role, options)
    diff = role.permission_diff options[:permissions]
    return if diff.empty?
    rename_existing role, original_name
    create_from_seeds original_name, options
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

  def create_from_seeds(name, options)
    SeedHelper.create_role name, options.merge(:update_permissions => false), 0, false
  end

  def process_default_role
    Role.default.update_attribute :origin, "foreman"
  end
end
