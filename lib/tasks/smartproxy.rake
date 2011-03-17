# The logic goes like this:
#  Smartproxy name must be unique
#   smartproxy hostname is used instead of name

require 'resolv'
desc <<-END_DESC
  Migrate each host's textual puppetmaster value over to a reference to a smart proxy

  The smart proxies should be declared using a FQDN before this operation. The procedure is as follows
    find all smart-proxies that support puppetca and their aliases
    for each host match the fqdn of the puppetmaster with the list
END_DESC
namespace :smartproxy do
  task :migrate => :environment do

    proxies = Feature.find_by_name("Puppet CA").smart_proxies
    proxies.map! do |proxy|
      class << proxy
        attr_accessor :names
        def include? hostname
          names.include? hostname
        end
        # # This creates a list of names that include the proxy's fqdn plus pupppet.domain, if puppet is an alias for host
        def load_aliases
          @names = [hostname]
          resolv = Resolv.new()
          domain = hostname.match(/^[^\.]+(.*)/)[1]
          begin
            pm_ip    = resolv.getaddress("puppet" + domain)
            proxy_ip = resolv.getaddress(hostname)
            @names.unshift("puppet" + domain) if pm_ip == proxy_ip
          rescue
          end
          self
        end
      end
      proxy.load_aliases
    end
    puts "Checking for the use of :-"
    for proxy in proxies
      puts proxy.names.join ", "
    end
    for host in Host.all
      next if host.puppetca?

      for proxy in proxies
        fqpm = host.pm_fqdn
        if proxy.include?(fqpm)
          # The proxy's name or puppet alias is the same as the fully qualified puppetmaster_name
          host.update_attribute(:puppetproxy_id, proxy.id)
          puts "Updated #{host.name} to use the #{proxy.name} smart proxy"
        end
      end
      puts "Failed to map #{host.name}'s puppetmaster(#{host.pm_fqdn}) to a smart proxy" if host.puppetproxy.nil?
    end
  end
end