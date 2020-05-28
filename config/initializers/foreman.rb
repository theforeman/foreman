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

unless Foreman.in_rake?('db:create') || Foreman.in_rake?('db:drop')
  Foreman::SettingManager.ensure_classes_loaded!
  Foreman.setting_manager.load
end

# load topbar
Menu::Loader.load

# clear our users topbar cache
# The users table may not be exist during initial migration of the database
TopbarSweeper.expire_cache_all_users if (User.table_exists? rescue false)

Foreman::Plugin.medium_providers.register MediumProviders::Default
