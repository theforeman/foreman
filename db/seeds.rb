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

    permissions.each do |permission|
      filtering            = filter.filterings.build
      filtering.permission = permission
    end

    filter.save!
  end
end

def create_role(role_name, permission_names, builtin)
  return if Role.find_by_name(role_name)
  return if audit_modified?(Role, role_name) && (builtin == 0)

  role         = Role.new(:name => role_name)
  role.builtin = builtin
  role.save!
  permissions = Permission.where(:name => permission_names)
  create_filters(role, permissions)
end

# now we load all seed files
foreman_seeds = Dir.glob(Rails.root + 'db/seeds.d/*.rb')

Foreman::Plugin.registered_plugins.each do |name, plugin|
  begin
    engine = (name.to_s.tr('-', '_').camelize + '::Engine').constantize
    foreman_seeds += Dir.glob(engine.root + 'db/seeds.d/*.rb')
  rescue NameError => e
    Foreman::Logging.exception("Failed to register plugin #{ name }", e)
  end
end

foreman_seeds = foreman_seeds.sort do |a, b|
  a.split('/').last <=> b.split('/').last
end

foreman_seeds.each do |seed|
  puts "Seeding #{seed}" unless Rails.env.test?
  load seed
end
puts "All seed files executed" unless Rails.env.test?
