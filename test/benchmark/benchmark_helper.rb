require 'benchmark/ips'

require File.expand_path('../../../config/environment', __FILE__)

unless Rails.env.production? && !Rails.configuration.database_configuration["production"]["migrate"]
  puts "Rails must be in production (set RAILS_ENV) and database must have migrations turned off!"
  puts "Please add similar configuration to your config/database.yml:"
  puts <<EOS
production:
  adapter: sqlite3
  database: ":memory:"
  migrate: false
  pool: 1
  timeout: 1000
EOS
  exit 1
end

load "#{Rails.root}/db/schema.rb"
require 'factory_bot_rails'

def foreman_benchmark
  GC.start
  yield
  stats = GC.stat
  puts "Memory stats"
  puts "Total objects allocated: #{stats[:total_allocated_objects]}"
  puts "Total heap pages allocated: #{stats[:total_allocated_pages]}"
end
