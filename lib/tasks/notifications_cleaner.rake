namespace :notifications do
  desc "Clean expired notification
        Arguments can be a specific time, a group name or a blueprint name
        With no arguments, all expired notifications will removed
        Examples:
        rake notifications:clean['08:00 AM'] -
          - Will clean all expired notifications until 08:00 AM today
        rake notifications:clean['2017-04-20', 'group1'] -
          - Will clean all expired notifications until the given date, and associated to group1
        rake notifications:clean[,,'blueprint_name'] -
          - Will clean all expired notifications which belongs to the given blueprint name"

  task :clean, [:time, :group, :blueprint] => :environment do |t, args|
    puts 'Starting expired notifications clean up...'
    begin
      cleaner = UINotifications::CleanExpired.new(blueprint: args.blueprint, group: args.group,
        expired_at: args.time)
      cleaner.clean!
      puts "Finished, cleaned #{cleaner.deleted_count} notifications"
    rescue => error
      puts "Failed to clean notification: #{error}"
    end
  end

  desc "Clean all notifications regardless of expiry
        Optionally pass a blueprint name to only clean notifications of that blueprint
        With no arguments, all notifications will be removed
        Examples:
        rake notifications:clean_all -
          - Will clean all notifications
        rake notifications:clean_all['blueprint_name'] -
          - Will clean all notifications belonging to the given blueprint name"

  task :clean_all, [:blueprint] => :environment do |t, args|
    message = args.blueprint.present? ? "Starting full notifications clean up for blueprint '#{args.blueprint}'..." : 'Starting full notifications clean up...'
    puts message
    begin
      cleaner = UINotifications::CleanAll.new(blueprint: args.blueprint)
      cleaner.clean!
      puts "Finished, cleaned #{cleaner.deleted_count} notifications"
    rescue => error
      puts "Failed to clean notifications: #{error}"
    end
  end
end
