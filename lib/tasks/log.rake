desc 'Log output of ActiveRecord actions to stdout'
task :log => :environment do
  ActiveRecord::Base.logger = Logger.new($stdout)
end
