require Rails.root + 'db/seeds.d/02-roles_list.rb'

class LockSeededRoles < ActiveRecord::Migration
  def up
    Role.reset_column_information
    ::RolesList.role_names.map do |role_name|
      role = Role.find_by :name => role_name
      return unless role
      role.update_attribute(:origin, "foreman")
    end
  end

  def down
    ::RolesList.role_names.map do |role_name|
      role = Role.find_by :name => role_name
      return unless role
      role.update_attribute(:origin, "foreman")
    end
  end
end
