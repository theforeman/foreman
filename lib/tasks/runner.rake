desc 'Run Ruby code in the Foreman application context'
task :runner => 'dynflow:client' do
  flags = ARGV.drop_while { |argument| argument != '--' }
  flags.shift

  require 'rails/command'
  User.current = User.anonymous_console_admin
  ::Rails::Command.invoke('runner', flags)
end
