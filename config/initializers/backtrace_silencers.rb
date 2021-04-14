# Be sure to restart your server when you modify this file.

# You can add backtrace silencers for libraries that you're using but don't wish to see in your backtraces.

# keep the lines from plugins in the backtrace
Rails.backtrace_cleaner.remove_silencers!
Rails.backtrace_cleaner.add_silencer do |line|
  line !~ Rails::BacktraceCleaner::APP_DIRS_PATTERN &&
      !(Foreman::Plugin.all.any? { |plugin| !plugin.name.nil? && line.include?(plugin.name) })
end

# You can also remove all the silencers if you're trying do debug a problem that might steem from framework code.
# Rails.backtrace_cleaner.remove_silencers!
