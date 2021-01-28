# stdlib dependencies
require 'English'

# Registries from app/registries/
# All are loaded and populated early but are loaded only once
require_dependency 'foreman/access_permissions'
require_dependency 'menu/loader'
require_dependency 'foreman/plugin'

# Other internal dependencies, may be autoloaded
require_dependency 'foreman/foreman_url_renderer'
require_dependency 'foreman/controller'
require_dependency 'net'
require_dependency 'foreman/provision' if SETTINGS[:unattended]
require_dependency 'foreman'
require_dependency 'fog_extensions'

# We may be executing something like rake db:migrate:reset, which destroys this table
# only continue if the table exists
if (Setting.table_exists? rescue(false))
  # in this phase, the classes are not fully loaded yet, load them
  Dir[
    File.join(Rails.root, "app/models/setting.rb"),
    File.join(Rails.root, "app/models/setting/*.rb"),
  ].each do |f|
    require_dependency(f)
  end

  Setting.descendants.each(&:load_defaults)
end

# load topbar
Menu::Loader.load

# clear our users topbar cache
# The users table may not be exist during initial migration of the database
TopbarSweeper.expire_cache_all_users if (User.table_exists? rescue false)

Foreman::Plugin.initialize_default_registries
Foreman::Plugin.medium_providers_registry.register MediumProviders::Default

Rails.application.config.to_prepare do
  Foreman.input_types_registry.register(InputType::UserInput)
  Foreman.input_types_registry.register(InputType::FactInput)
  Foreman.input_types_registry.register(InputType::VariableInput)
end
