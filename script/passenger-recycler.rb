#!/usr/bin/env ruby
#
# Trivial Passenger memory monitor installed via /etc/cron.hourly/. To modify
# configuration create /etc/foreman/passenger-recycler.rb.conf file.
#

CONFIG = '/etc/foreman/passenger-recycler.rb.conf'
load CONFIG if File.readable?(CONFIG)
ENABLED ||= true
MAX_PRIV_RSS_MEMORY ||= 2_000_000
GRACEFUL_SHUTDOWN_SLEEP ||= 120
KILL_BUSY ||= true
SEND_STATUS ||= true
exit 0 unless ENABLED

def running?(pid)
  return Process.getpgid(pid) != -1
rescue Errno::ESRCH
  return false
end

require 'phusion_passenger'
require 'phusion_passenger/platform_info'
require 'phusion_passenger/platform_info/ruby'
require 'phusion_passenger/admin_tools/memory_stats'
stats = PhusionPassenger::AdminTools::MemoryStats.new
unless stats.platform_provides_private_dirty_rss_information?
  puts "Please run as root or platform unsupported"
  exit 1
end
stats.passenger_processes.each do |p|
  if p.private_dirty_rss > MAX_PRIV_RSS_MEMORY
    pid = p.pid.to_i
    started = `ps -p#{pid} -o start=`.strip rescue '?'
    status_ps = `ps -p#{pid} -u`
    status_all = `passenger-status`
    status_backtraces = `passenger-status --show=backtraces`
    puts "Terminating #{pid} (started #{started}) with private dirty RSS size of #{p.private_dirty_rss} MB"
    Process.kill "SIGUSR1", pid
    sleep GRACEFUL_SHUTDOWN_SLEEP
    if running?(pid) && KILL_BUSY
      puts "Process #{pid} is still running, sending SIGKILL"
      Process.kill "KILL", pid
      sleep 5
    end
    if running?(pid)
      puts "Process #{pid} still terminating, moving on..."
    else
      puts "Process successfully #{pid} terminated"
    end
    if SEND_STATUS
      puts status_ps
      puts status_all
      puts status_backtraces
    end
    exit 1
  end
end
exit 0
