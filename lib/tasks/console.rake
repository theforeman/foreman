task :console => :environment do
  flags = (ARGV.drop_while { |s| s != "--" }) || []
  flags.shift
  require 'rails/command'
  ::Rails::Command.invoke('console', flags)
end
