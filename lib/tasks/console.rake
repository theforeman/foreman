task :console => :environment do
  flags = (ARGV.drop_while { |s| s != "--" }) || []
  flags.shift
  # Extra arguments make IRB attempt to open MagicFile('argument')
  # on Rails 4 when starting a console.
  ARGV.clear
  require 'rails/commands/console'
  Rails::Console.start(Rails.application, Rails::Console.parse_arguments(flags))
end
