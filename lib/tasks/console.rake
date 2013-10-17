desc 'Load Rails console, requires foreman-console'
task :console => :environment do
  require 'rails/commands/console'
  Rails::Console.start(Rails.application)
end
