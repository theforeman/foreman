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
    counts = TrendCounter.group([:trend_id, :created_at]).count

    # Keep only those pairs that have more than one record
    dupes = counts.select{|attrs, count| count > 1}

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

end
