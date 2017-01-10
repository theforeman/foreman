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

def audit_modified?(type, name, attributes = {})
  Foreman::Deprecation.deprecation_warning('1.17', "This method will be removed, use SeedHelper.audit_modified? instead.")
  SeedHelper.audit_modified? type, name, attributes
end

# now we load all seed files
foreman_seeds = Dir.glob(Rails.root + 'db/seeds.d/*.rb')

Foreman::Plugin.registered_plugins.each do |name, plugin|
  begin
    engine = (name.to_s.tr('-', '_').camelize + '::Engine').constantize
    foreman_seeds += Dir.glob(engine.root + 'db/seeds.d/*.rb')
  rescue NameError => e
    Foreman::Logging.exception("Failed to register plugin #{name}", e)
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
