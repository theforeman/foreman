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
      cleaner = UINotifications::CleanExpired.new({blueprint: args.blueprint, group: args.group,
                                                   expired_at: args.time}.compact)
      cleaner.clean!
      puts "Finished, cleaned #{cleaner.deleted_count} notifications"
    rescue => error
      puts "Failed to clean notification: #{error}"
    end
  end
end
