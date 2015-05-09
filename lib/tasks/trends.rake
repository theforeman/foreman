namespace :trends do
  desc 'Create Trend counts'
  task :counter => :environment do
    TrendImporter.update!
  end

  desc 'Clean Duplicates'
  task :clean => :environment do
    # This cleans out the duplicates created by multiple cron jobs.
    # Note this can take a few minutes to run as the table is huge

    # Get a hash of all TrendCounter pairs and how many records of each pair
    # Keep only those pairs that have more than one record
    dupes = TrendCounter.having('count(*) > 1').group([:trend_id, :created_at]).count

    # Map objects by the attributes
    object_groups = dupes.map do |attrs, count|
      TrendCounter.where(:trend_id => attrs[0], :created_at => attrs[1])
    end

    # Take each group and destroy the extra records.
    object_groups.each do |group|
      group.each_with_index do |object, index|
        object.destroy unless index == 0
      end
    end
  end

  desc 'Reduces amount of points for each trend group'
  task :reduce => :environment do
    start = Time.now

    trends = Trend.pluck(:id)
    trends_count = trends.length
    current_record = 0

    trends.each do |trend_id|
      puts "Working on trend_id #{trend_id}, #{(current_record += 1)} of #{trends_count}"

      current_interval = TrendCounter.where(trend_id: trend_id).order(:created_at).first
      next if current_interval.nil?

      current_interval.interval_start = current_interval.created_at
      while next_interval = TrendCounter.where(trend_id: trend_id)
                                        .where("created_at > ? and count <> ?", current_interval.created_at, current_interval.count)
                                        .order(:created_at).first
        current_interval.interval_end = next_interval.created_at
        current_interval.save!
        current_interval = next_interval
        current_interval.interval_start = current_interval.created_at
      end
      current_interval.save!
    end

    TrendCounter.unscoped.where(interval_start: nil).delete_all

    puts "It took #{Time.now - start} seconds to complete"
  end
end
