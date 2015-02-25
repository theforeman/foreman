# Load the rails application
require File.expand_path('../application', __FILE__)

#Add timestamps and severity to environment.log
class Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.strftime('%Y-%m-%d %H:%M:%S')} [#{severity[0]}] #{msg}\n"
  end
end

# Initialize the rails application
Foreman::Application.initialize!
