# TRANSLATORS: do not translate
desc <<-END_DESC
  This task search hosts that have been out of sync for longer than
  twice your out of sync interval by using DNS lookups and ping.

  Once it finishes scanning, it will prompt you to delete hosts that
  don't have DNS entries nor respond to ping.

  You can provide the number of seconds after which a host is considered
  out of sync by using the environment variable 'OUTOFSYNC_INTERVAL'.

  Legend:
  "." - pingable
  "x" - no ping response

  Examples:
    rake hosts:scan_out_of_sync RAILS_ENV="production"
    rake hosts:scan_out_of_sync RAILS_ENV="production" OUTOFSYNC_INTERVAL=3600

END_DESC

namespace :hosts do
  task :scan_out_of_sync => :environment do
    require 'net/ping/external'
    require 'resolv'

    def printhosts(list, description)
      unless list.empty?
        puts
        puts "Found #{list.size} #{description}:"
        puts "Name".ljust(40) + "Environment".ljust(20) + "Last Report"
        puts '*' * 80
        list.each do |h|
          puts h.name.ljust(40) + h.environment.to_s.ljust(20) + h.last_report.to_s(:short)
        end
      end
    end

    def out_of_sync_interval
      return ENV['OUTOFSYNC_INTERVAL'] if ENV['OUTOFSYNC_INTERVAL'].present?
      2 * (Setting[:outofsync_interval])
    end

    pingable = []
    missingdns = []
    offline = []

    Host::Managed.out_of_sync(out_of_sync_interval.to_i.seconds.ago).
      order('environment_id ASC').collect do |host|
      $stdout.flush
      ip = Resolv::DNS.new.getaddress(host.name).to_s rescue nil
      if ip.empty?
        missingdns << host
      else
        if host.ip.blank?
          puts "Host #{host.name} does not have an IP in Foreman. It resolved to IP: '#{ip}' through DNS. Skipping..."
          next
        end
        all_host_ips = host.interfaces.pluck(:ip)
        puts "Conflict IP address for #{host.name}" unless all_host_ips.include? ip
        begin
          if Net::Ping::External.new(host.ip).ping
            print "."
            pingable << host
          else
            print "x"
            offline << host
          end
        rescue => e
          Rails.logger.warn "Could not ping host #{host.name} due to an exception: #{e} - skipping"
        end
      end
    end
    puts

    if missingdns.empty?
      puts "All out of sync hosts exist in DNS"
    else
      printhosts(missingdns, "hosts with no DNS entry")
      puts "Are you sure you want to continue? This task will delete the hosts above [y/N]"
      input = STDIN.gets.chomp
      abort("No action taken. Bye!") unless input.downcase == "y"

      missingdns.each do |h|
        print "Destroying host #{h.fqdn}... "
        h.destroy
        puts "DESTROYED"
      end
    end

    printhosts(offline, "offline hosts")
    printhosts(pingable, "online hosts which are not reporting back")
  end
end
