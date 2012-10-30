namespace :trends do

  desc 'Create daily Trend counts'
  task :counter => :environment do
    TrendImporter.update!
  end
end