require 'foreman/cron'

# Register built-in recurring tasks for each cadence.
# Plugins can also call Foreman::Cron.register(:daily, 'my_plugin:task').
Foreman::Cron.register(:hourly, 'ldap:refresh_usergroups')

Foreman::Cron.register(:daily,  'reports:daily')
Foreman::Cron.register(:daily,  'db:sessions:clear')
Foreman::Cron.register(:daily,  'reports:expire')
Foreman::Cron.register(:daily,  'audits:expire')

Foreman::Cron.register(:weekly, 'reports:weekly')
Foreman::Cron.register(:weekly, 'notifications:clean')

Foreman::Cron.register(:monthly, 'reports:monthly')

namespace :cron do
  desc 'Run hourly Foreman cron jobs'
  task hourly: :environment do
    failed = Foreman::Cron.run(:hourly)
    raise "One or more hourly cron tasks failed" if failed
  end

  desc 'Run daily Foreman cron jobs'
  task daily: :environment do
    failed = Foreman::Cron.run(:daily)
    raise "One or more daily cron tasks failed" if failed
  end

  desc 'Run weekly Foreman cron jobs'
  task weekly: :environment do
    failed = Foreman::Cron.run(:weekly)
    raise "One or more weekly cron tasks failed" if failed
  end

  desc 'Run monthly Foreman cron jobs'
  task monthly: :environment do
    failed = Foreman::Cron.run(:monthly)
    raise "One or more monthly cron tasks failed" if failed
  end
end
