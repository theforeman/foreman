# Author: Roberto Moral Denche (Telmo : telmox@gmail.com)
# Description: The tasks defined in this Rakefile will help you populate some of the
#    fields in Foreman with what is already present in your database from
#    StoragedConfig.
require 'rake/clean'
require 'yaml'

namespace :puppet do
  namespace :import do
    desc "Imports hosts and facts from existings YAML files, use dir= to override default directory"
    task :hosts_and_facts, [:dir] => :environment do |t, args|
      dir = args[:dir] || ENV['dir'] || '/opt/puppetlabs/server/data/puppetserver/yaml/facts'
      puts "Importing from #{dir}"
      Dir["#{dir}/*.yaml"].each do |yaml|
        name = yaml.match(/.*\/(.*).yaml/)[1]
        puts "Importing #{name}"
        puppet_facts = File.read(yaml)
        facts_stripped_of_class_names = YAML.load(puppet_facts.gsub(/\!ruby\/object.*$/, ''))
        User.as_anonymous_admin do
          host = Host::Managed.import_host(facts_stripped_of_class_names['name'], 'puppet')
          HostFactImporter.new(host).import_facts(facts_stripped_of_class_names['values'])
        end
      end
    end
  end

  namespace :import do
    desc "
    Import your hosts classes and parameters classifications from another external node source.
    define script=/dir/node as the script which provides the external nodes information.
    This will only scan for hosts that already exists in our database, if you want to
    import hosts, use one of the other importers.
    YOU Must import your classes first!"

    task :external_nodes => :environment do
      User.as_anonymous_admin do
        if Puppetclass.count == 0
          $stdout.puts "You dont have any classes defined.. aborting!"
          exit(1)
        end

        if (script = ENV['script']).nil?
          $stdout.puts "You must define the old external nodes script to use. script=/path/node"
          exit(1)
        end

        Host.find_each do |host|
          $stdout.print "processing #{host.name} "
          nodeinfo = YAML.load `#{script} #{host.name}`
          if nodeinfo.is_a?(Hash)
            $stdout.puts "DONE" if host.importNode nodeinfo
          else
            $stdout.puts "ERROR: invalid output from external nodes"
          end
          $stdout.flush
        end
      end
    end
  end
end
