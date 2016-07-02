# Plugin migrations might not run during a failed run of foreman-installer.
# However, the application can be started when there are missing migrations.
# In that case,if the user checks the application, everything will look fine.
# When migrations are pending, permissions from plugins will not be
# loaded into Foreman::AccessControl - app/services/foreman/plugin.rb#L217
#
# This is a problem for plugins. I can set the 'view_activation_keys'
# permissions because it's on the db, but if it's not loaded, it's
# useless. This means the user won't be able to use these permissions and
# won't be able to access any plugin resource.
#
# Rails has a helper to catch this automatically, but this initializer will
# show the foreman-rake command we intend users to use to run migrations.

if !Foreman.in_rake? &&
    ActiveRecord::Migrator.needs_migration?(ActiveRecord::Base.connection)
  raise Foreman::Exception.new(
    N_('Some database migrations are pending. '\
       'Please run `foreman-rake db:migrate` and restart the application to continue.'))
end
