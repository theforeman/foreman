namespace :trends do
  desc 'Create Trend counts'
  task :counter => :environment do
    TrendImporter.update!
  end

  desc 'Reduces amount of points for each trend group'
  task :reduce => :environment do
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    trends = Trend.pluck(:id)
    trends_count = trends.length
    current_record = 0

    trends.each do |trend_id|
      puts "Working on trend_id #{trend_id}, #{(current_record += 1)} of #{trends_count}" unless Rails.env.test?

      current_interval = TrendCounter.where(trend_id: trend_id).order(:created_at).first
      next if current_interval.nil?

      current_interval.interval_start = current_interval.created_at
      while (next_interval = TrendCounter.where(trend_id: trend_id)
                                         .where("created_at > ? and count <> ?", current_interval.created_at, current_interval.count)
                                         .order(:created_at).first)
        current_interval.interval_end = next_interval.created_at
        current_interval.save!
        current_interval = next_interval
        current_interval.interval_start = current_interval.created_at
      end
      current_interval.save!
    end

    TrendCounter.unscoped.where(interval_start: nil).delete_all

    puts "It took #{Process.clock_gettime(Process::CLOCK_MONOTONIC) - start} seconds to complete" unless Rails.env.test?
  end
end
