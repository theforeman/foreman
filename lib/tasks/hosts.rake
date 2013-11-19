# TRANSLATORS: do not translate
desc <<-END_DESC
  Try to figure out the out of sync systems real status

  try to search them by DNS lookups and ping, if a system is not in DNS it will allow you to delete it.

  legend:
  "." - pingable
  "x" - no ping response

  Example:
    rake systems:scan_out_of_sync RAILS_ENV="production"

END_DESC

namespace :systems do
  task :scan_out_of_sync => :environment do
    require 'ping'
    require 'resolv'

    def printsystems(list, description)
      unless list.empty?
        puts
        puts "found #{list.size} #{description} systems:"
        puts "Name".ljust(40)+"Environment".ljust(20)+"Last Report"
        puts "#{"*"*80}"
        list.each do |h|
          puts h.name.ljust(40) + h.environment.to_s.ljust(20) + h.last_report.to_s(:short)
        end
      end
    end

    pingable = []
    missingdns = []
    offline = []

    System.out_of_sync(1.hour.ago).all(:order => 'environment_id asc').collect do |system|
      $stdout.flush
      ip = Resolv::DNS.new.getaddress(system.name).to_s rescue nil
      if ip.empty?
        missingdns << system
      else
        puts "conflict IP address for #{system.name}" unless ip == system.ip
        if Ping.pingecho system.ip
          print "."
          pingable << system
        else
          print "x"
          offline << system
        end
      end
    end
    puts
    if missingdns.empty?
      puts "All out of sync systems exists in DNS"
    else
      printsystems(missingdns, "systems with no DNS entry")
      puts "ctrl-c to abort - any other key to remove these systems"
      $stdin.gets

      missingdns.each {|h| h.destroy }
    end

    printsystems(offline, "offline systems")
    printsystems(pingable, "online systems which are not running puppet")
  end
end
