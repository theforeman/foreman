task :console => :environment do
  require 'rails/commands/console'

  ARGV.delete("console")
  ARGV.delete("--trace")

  Rails::Console.start(Rails.application)
end
