namespace :errors do
  desc <<~END_DESC
    Fetches log for given request id

    This task is useful to get log for given request id from logs in log directory. The request_id is required.
    You can also specify log file where request logs has been saved. Default option is 'production.log'.

    Available attributes:
      * request_id = Request id from 500 page
      * log_file = specify another log file to lookup (default is 'production.log')

    Examples:
      # foreman-rake errors:fetch_log request_id=aabbccss5 [log_file=development.log]
  END_DESC

  task :fetch_log => :environment do
    request_id = ENV['request_id']
    logfile = ENV['log_file'] || 'production.log' # default file where we want to find is production.log
    unless request_id
      puts "Can't find log without request_id"
      exit(1)
    end
    type = Foreman::Logging.config[:type]
    unless type == 'file'
      puts "This rake task only support log file, you're using #{type}"
      puts "You can search the logs in #{type} for request_id #{request_id}"
      exit(1)
    end
    if Foreman::Logging.config[:layout] != 'multiline_request_pattern'
      puts "Warning: Logging layout is not multiline_request_pattern."
      puts "This output of this command can be incomplete."
    end
    file_path = File.join(Foreman::Logging.log_directory, logfile)
    unless File.exist?(file_path)
      puts "Can't find log file #{file_path}"
      exit(1)
    end
    result = `grep "#{request_id}" "#{file_path}"`
    if result.empty?
      puts "Can't find log for request_id"
      exit(1)
    end
    puts result
    puts "\n"
    puts "Foreman version: #{Foreman::Version.new.full}"
    unless (plugins = Foreman::Plugin.all).empty?
      puts "Plugins: "
      plugins.each do |plugin|
        puts " - #{plugin.name} #{plugin.version}"
      end
    end
  end
end
