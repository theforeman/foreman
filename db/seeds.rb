# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# This file must remain idempotent.
#
# Please ensure that all templates are submitted to community-templates, then they will be synced in.

# define all helpers here

def format_errors(model = nil)
  return '(nil found)' if model.nil?
  model.errors.full_messages.join(';')
end

# Check if audits show an object was renamed or deleted
def audit_modified?(type, name)
  au = Audit.where(:auditable_type => type, :auditable_name => name)
  return true if au.where(:action => :destroy).present?
  au.where(:action => :update).each do |audit|
    return true if audit.audited_changes['name'].is_a?(Array) && audit.audited_changes['name'].first == name
  end
  false
end

def create_filters(role, collection)
  collection.group_by(&:resource_type).each do |resource, permissions|
    filter      = Filter.new
    filter.role = role
    filter.save!

    permissions.each do |permission|
      filtering            = Filtering.new
      filtering.filter     = filter
      filtering.permission = permission
      filtering.save!
    end
  end
end

def create_role(role_name, permission_names, builtin)
  return if Role.find_by_name(role_name)
  return if audit_modified? Role, role_name && builtin == 0

  role         = Role.new(:name => role_name)
  role.builtin = builtin
  role.save!
  permissions = Permission.find_all_by_name permission_names
  create_filters(role, permissions)
end

# now we load all seed files
Dir.glob(Rails.root + 'db/seeds.d/*.rb').sort.each do |seed|
  puts "Seeding #{seed}"
  require seed
end
puts "All seed files executed"
