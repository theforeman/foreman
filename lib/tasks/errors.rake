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
    unless request_id
      puts "Can't find log without request_id"
      exit(1)
    end

    puts "Foreman version: #{Foreman::Version.new.full}"
    unless (plugins = Foreman::Plugin.all).empty?
      puts "Plugins: "
      plugins.each do |plugin|
        puts " - #{plugin.name} #{plugin.version}"
      end
    end
    puts

    type = Foreman::Logging.config[:type]
    lines = case type
            when 'file'
              logfile = ENV['log_file'] || 'production.log' # default file where we want to find is production.log
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
              result
            when 'journald'
              require 'open3'
              require 'etc'

              cmd = ['journalctl', "REQUEST=#{request_id}"]
              stdout, stderr, _status = Open3.capture3(cmd)

              if stdout.include?('No entries')
                puts "Can't find log for request_id"
                exit(1)
              elsif stderr.include?('No journal files were opened due to insufficient permissions.')
                puts "User #{Etc.getpwuid(Process.euid).name} could not access system journal due to missing privileges."
                puts "Please run the following command as a user with access to the system journal."
                print cmd.join(' ')
              end
              stdout
            else
              puts "This rake task only supports retrieving logs from a log file or journald, you're using #{type}"
              puts "You can search the logs in #{type} for request_id #{request_id}"
              exit(1)
            end
    puts lines
  end
end
