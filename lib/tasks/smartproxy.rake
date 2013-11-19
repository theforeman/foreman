# The logic goes like this:
#  Smartproxy name must be unique
#   smartproxy systemname is used instead of name

require 'resolv'
# TRANSLATORS: do not translate
desc <<-END_DESC
  Migrate each system's textual puppetmaster value over to a reference to a smart proxy

  The smart proxies should be declared using a FQDN before this operation. The procedure is as follows
    find all smart-proxies that support puppetca and their aliases
    for each system match the fqdn of the puppetmaster with the list
END_DESC
namespace :smartproxy do
  task :migrate => :environment do

    proxies = Feature.find_by_name("Puppet").smart_proxies
    proxies.map! do |proxy|
      class << proxy
        attr_accessor :names
        def include? systemname
          names.include? systemname
        end
        # # This creates a list of names that include the proxy's fqdn plus pupppet.domain, if puppet is an alias for system
        def load_aliases
          @names = [systemname]
          resolv = Resolv.new()
          domain = systemname.match(/^[^\.]+(.*)/)[1]
          begin
            pm_ip    = resolv.getaddress("puppet" + domain)
            proxy_ip = resolv.getaddress(systemname)
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
    for system in System.all
      next if system.puppetca?

      for proxy in proxies
        fqpm = system.pm_fqdn
        if proxy.include?(fqpm)
          # The proxy's name or puppet alias is the same as the fully qualified puppetmaster_name
          system.update_attribute(:puppet_proxy_id, proxy.id)
          puts "Updated #{system.name} to use the #{proxy.name} smart proxy"
        end
      end
      puts "Failed to map #{system.name}'s puppetmaster(#{system.pm_fqdn}) to a smart proxy" if system.puppet_proxy.nil?
    end
  end
end
