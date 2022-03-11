# stdlib dependencies
require 'English'

# Registries from app/registries/
# All are loaded and populated early but are loaded only once
require_dependency 'foreman/access_permissions'
require_dependency 'foreman/plugin'
require_dependency 'foreman/settings'

# Other internal dependencies, may be autoloaded
require 'net'
require 'foreman/provision'

# in this phase, the classes are not fully loaded yet, load them

Rails.application.config.before_initialize do
  # load topbar
  Menu::Loader.load
end

Foreman.settings.load_definitions

# We may be executing something like rake db:migrate:reset, which destroys this table
# only continue if the table exists

Foreman::Plugin.initialize_default_registries
Foreman::Plugin.medium_providers_registry.register MediumProviders::Default

Rails.application.config.after_initialize do
  Foreman::Plugin.registered_plugins.each do |_name, plugin|
    plugin.finalize_setup!
  end
end

Rails.application.config.to_prepare do
  # clear our users topbar cache
  # The users table may not be exist during initial migration of the database
  TopbarSweeper.expire_cache_all_users if (User.table_exists? rescue false)

  if (Setting.table_exists? rescue(false))
    # Force reload settings after all plugins have loaded and on code reload
    Dir[
      Rails.root.join('app', 'models', 'setting.rb'),
      Rails.root.join('app', 'models', 'setting', '*.rb'),
      *Foreman::Plugin.registered_plugins.map { |_n, p| p.engine&.root&.join('app', 'models', 'setting', '*.rb') }.compact
    ].each do |f|
      require_dependency(f)
    end
    Foreman.settings.load unless Foreman.in_setup_db_rake?
  end

  Foreman.input_types_registry.register(InputType::UserInput)
  Foreman.input_types_registry.register(InputType::FactInput)
  Foreman.input_types_registry.register(InputType::VariableInput)

  ReportImporter.register_smart_proxy_feature("Puppet")
end
