task :console => :environment do
  # Extra arguments make IRB attempt to open MagicFile('argument')
  # on Rails 4 when starting a console.
  ARGV = []
  require 'rails/commands/console'
  Rails::Console.start(Rails.application)
end
