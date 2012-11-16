namespace :trends do

  desc 'Create Trend counts'
  task :counter => :environment do
    TrendImporter.update!
  end
end