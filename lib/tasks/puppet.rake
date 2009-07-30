# Author: Roberto Moral Denche (Telmo : telmox@gmail.com)
# Description: The tasks defined in this Rakefile will help you populate some of the
#		fiels in GNI with what is already present in your database from 
#		StoragedConfig.

namespace :puppet do
  namespace :migrate do
    desc "Populates the host fields in GNI based on your StoredConfig DB"
    task :populate_hosts => :environment do
      helper = Array.new
      Host.all.each do |host|
        begin
          host.mac = host.fact(:macaddress)[0].value
          host.domain = Domain.find_or_create_by_name host.fact(:domain)[0].value
          host.architecture = Architecture.find_or_create_by_name host.fact(:architecture)[0].value
          host.environment = Environment.find_or_create_by_name host.fact(:environment)[0].value

          os = host.fact(:operatingsystem)[0].value
          os_rel = host.fact(:operatingsystemrelease)[0].value
          host.operatingsystem = Operatingsystem.find_or_create_by_name_and_major os, os_rel
          puts "#{host.hostname}: #{host.errors.full_messages}" unless host.save
        rescue
          $stderr.puts $!
        end
      end
    end
  end
end
