# Author: Roberto Moral Denche (Telmo : telmox@gmail.com)
# Description: The tasks defined in this Rakefile will help you populate some of the
#		fiels in GNI with what is already present in your database from 
#		StoragedConfig.

namespace :puppet do
  namespace :migrate do
    desc "Populates the host fields in GNI based on your StoredConfig DB"
    task :populate_hosts => :environment do
      counter = 0
      Host.find_each do |host|
        if host.populateFieldsFromFacts
          counter += 1
        else
          $stderr.puts "#{host.hostname}: #{host.errors.full_messages}"
        end
      end
      puts "Imported #{counter} hosts out of #{Host.count} Hosts" unless counter == 0
    end
  end
  namespace :import do
    desc "Imports hosts and facts from existings YAML files, use dir= to override default directory"
    task :hosts_and_facts => :environment do
      dir = ENV['dir'] || "#{Puppet[:vardir]}/facts/yaml"
      puts "Importing from #{dir}"
      Dir["#{dir}/*.yaml"].each do |yaml|
        name = yaml.match(/.*\/(.*).yaml/)[1]
        puts "importing #{name}"
        h=Host.find_or_create_by_name name
        h.importFacts File.read(yaml)
      end
    end
  end
end
