# TRANSLATORS: do not translate
desc <<-END_DESC
  Try to figure out the out of sync hosts real status

  try to search them by DNS lookups and ping, if a host is not in DNS it will allow you to delete it.

  legend: 
  "." - pingable
  "x" - no ping response

  Example:
    rake hosts:scan_out_of_sync RAILS_ENV="production"

END_DESC

namespace :hosts do
  task :scan_out_of_sync => :environment do
    require 'ping'
    require 'resolv'

    def printhosts(list, description)
      unless list.empty?
        puts
        puts "found #{list.size} #{description} hosts:"
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

    Host.out_of_sync(1.hour.ago).all(:order => 'environment_id asc').collect do |host|
      $stdout.flush 
      ip = Resolv::DNS.new.getaddress(host.name).to_s rescue nil
      if ip.empty?
        missingdns << host
      else
        puts "conflict IP address for #{host.name}" unless ip == host.ip
        if Ping.pingecho host.ip
          print "."
          pingable << host
        else
          print "x"
          offline << host
        end
      end
    end
    puts
    if missingdns.empty?
      puts "All out of sync hosts exists in DNS"
    else
      printhosts(missingdns, "hosts with no DNS entry")
      puts "ctrl-c to abort - any other key to remove these hosts"
      $stdin.gets

      missingdns.each {|h| h.destroy }
    end

    printhosts(offline, "offline hosts")
    printhosts(pingable, "online hosts which are not running puppet")
  end
end
