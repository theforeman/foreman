# Author: Roberto Moral Denche (Telmo : telmox@gmail.com)
# Description: The tasks defined in this Rakefile will help you populate some of the
#		fiels in Foreman with what is already present in your database from
#		StoragedConfig.

namespace :puppet do
  namespace :migrate do
    desc "Populates the host fields in Foreman based on your StoredConfig DB"
    task :populate_hosts => :environment do
      counter = 0
      Host.find_each do |host|
        if host.fact_values.size == 0
          $stderr.puts "#{host.hostname} has no facts, skipping"
          next
        end

        if host.populateFieldsFromFacts
          counter += 1
        else
          $stderr.puts "#{host.hostname}: #{host.errors.full_messages.join(", ")}"
        end
      end
      puts "Imported #{counter} hosts out of #{Host.count} Hosts" unless counter == 0
    end
  end
  namespace :import do
    desc "Imports hosts and facts from existings YAML files, use dir= to override default directory"
    task :hosts_and_facts => :environment do
      dir = ENV['dir'] || "#{Puppet[:vardir]}/yaml/facts"
      puts "Importing from #{dir}"
      Dir["#{dir}/*.yaml"].each do |yaml|
        name = yaml.match(/.*\/(.*).yaml/)[1]
        puts "Importing #{name}"
        h=Host.find_or_create_by_name name
        h.importFacts File.read(yaml)
      end
    end
  end
  #TODO: remove old classes
  namespace :import do
    desc "Update puppet environments and classes"
    task :puppet_classes => :environment do
      ec, pc = Environment.count, Puppetclass.count
      Environment.importClasses
      puts "Environment   old:#{ec}\tcurrent:#{Environment.count}"
      puts "PuppetClasses old:#{pc}\tcurrent:#{Puppetclass.count}"
    end
  end
end
