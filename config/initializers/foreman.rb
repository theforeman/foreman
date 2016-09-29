require 'foreman/access_permissions'
require 'menu/loader'
require 'dashboard/loader'
require 'foreman/plugin'
require 'foreman/renderer'
require 'foreman/controller'
require 'net'
require 'foreman/provision' if SETTINGS[:unattended]
require 'foreman'
require 'filters_helper_overrides'
require 'English'
require 'fog_extensions'

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

#load topbar
Menu::Loader.load

#load dashboard widgets
Dashboard::Loader.load

# clear our users topbar cache
# The users table may not be exist during initial migration of the database
TopbarSweeper.expire_cache_all_users if User.table_exists?
