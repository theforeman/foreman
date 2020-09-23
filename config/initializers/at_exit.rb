#
# Graceful shutdown of web workers
#
# Note this is executed in a different context, Ruby on Rails application is
# not available, this includes Rails.env, Rails.logger, Rails.root and others.
#
# Signal.trap cannot be used as it is redefined in web server (Puma). Multiple
# at_exit blocks are allowed.
#

SHUTDOWN_LOGFILE = File.expand_path(__dir__ + "../../../log/shutdown.log")
PROMETHEUS_DIR = File.expand_path(__dir__ + "../../../tmp/prometheus")

def logmsg(message)
  File.open(SHUTDOWN_LOGFILE, 'a') { |f| f.puts "[#{Process.pid}] " + message }
end

def rotatelog
  return unless File.exist?(SHUTDOWN_LOGFILE)
  return if File.size(SHUTDOWN_LOGFILE) < 1_000_000
  FileUtils.rm_f(SHUTDOWN_LOGFILE)
end

def check_pid(pid)
  Process.getpgid(pid.to_i)
  true
rescue Errno::ESRCH
  false
end

def cleanup_prometheus
  # delete my own files
  logmsg "Deleting #{PROMETHEUS_DIR}/metric_*_#{Process.pid}.bin"
  FileUtils.rm_f(Dir.glob("#{PROMETHEUS_DIR}/metric_*_#{Process.pid}.bin"))
  # delete all leftovers
  Dir.glob("#{PROMETHEUS_DIR}/metric_*.bin").each do |temp_file|
    pid, = temp_file.to_s.match(/([0-9]+)\.bin/).captures
    unless check_pid(pid)
      logmsg "Deleting unused #{temp_file}"
      FileUtils.rm_f(temp_file)
    end
  end
end

def graceful_shutdown
  rotatelog
  logmsg "Graceful shutdown started"
  cleanup_prometheus
  logmsg "Graceful shutdown finished"
  # rubocop:disable Rails/Exit
  Kernel.exit
  # rubocop:enable Rails/Exit
end

at_exit do
  graceful_shutdown if (defined?(Foreman) && !Foreman.in_rake?)
end

if __FILE__ == $PROGRAM_NAME
  graceful_shutdown
end
