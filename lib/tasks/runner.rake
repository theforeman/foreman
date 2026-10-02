desc "Run Ruby code in the Foreman application context. Example: foreman-rake runner -- 'puts Host.count'"
task :runner => 'dynflow:client' do
  separator_index = ARGV.index('--')
  flags = separator_index ? ARGV[(separator_index + 1)..] : []

  Rake.application.top_level_tasks.replace(['runner'])

  require 'rails/command'
  User.current = User.anonymous_console_admin
  ::Rails::Command.invoke('runner', flags)
end
