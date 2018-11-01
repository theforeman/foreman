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
          host.import_facts(facts_stripped_of_class_names['values'].with_indifferent_access)
        end
      end
    end
  end
  namespace :import do
    desc "
    Update puppet environments and classes. Optional batch flag triggers run with no prompting\nUse proxy=<proxy name> to import from or get the first one by default"
    task :puppet_classes, [:batch, :envname] => :environment do |t, args|
      User.as_anonymous_admin do
        args.batch = args.batch == "true"
        proxies = SmartProxy.with_features("Puppet")

        if proxies.empty?
          puts "ERROR: We did not find at least one configured Smart Proxy with the Puppet feature"
          exit 1
        end
        if ENV["proxy"]
          proxy = proxies.select {|p| p.name == ENV["proxy"]}.first
          unless proxy.is_a?(SmartProxy)
            puts "Smart Proxies #{ENV['proxy']} was not found, aborting"
            exit 1
          end
        end
        proxy ||= proxies.first
        # Evaluate any changes that exist between the database of environments and puppetclasses and
        # the on-disk puppet installation
        begin
          puts "Evaluating possible changes to your installation" unless args.batch
          importer = PuppetClassImporter.new({ :url => proxy.url, :env => args.envname })
          changes  = importer.changes
        rescue => e
          if args.batch
            Rails.logger.error "Failed to refresh puppet classes: #{e}"
          else
            puts "Problems were detected during the evaluation phase"
            puts
            puts e.message.gsub(/<br\/>/, "\n") + "\n"
            puts
            puts "Please fix these issues and try again"
          end
          exit 1
        end

        if changes["new"].empty? && changes["obsolete"].empty?
          puts "No changes detected" unless args.batch
        else
          unless args.batch
            puts "Scheduled changes to your environment"
            ["new", "updated"].each do |c|
              puts "#{c.titleize} environments"
              changes[c].each do |env, classes|
                print "%-15s: %s\n" % [env, classes.keys.to_sentence]
              end
            end
            puts "Delete environments"
            changes["obsolete"].each do |env, classes|
              if classes.include? "_destroy_"
                print "%-15s: %s\n" % [env, "Remove environment"]
              else
                print "%-15s: %s\n" % [env, classes.to_sentence]
              end
            end
            puts
            print "Proceed with these modifications? <yes|no> "
            response = $stdin.gets

            exit(0) unless response =~ /^yes/
          end

          errors = ""
          # Apply the filtered changes to the database
          begin
            ['new', 'updated', 'obsolete'].each { |kind| changes[kind].each_key { |k| changes[kind.to_s][k] = changes[kind.to_s][k].to_json } }
            errors = PuppetClassImporter.new.obsolete_and_new(changes)
          rescue => e
            errors = e.message + "\n" + e.backtrace.join("\n")
          end
          if args.batch
            Rails.logger.warn "Failed to refresh puppet classes: #{errors}"
          else
            if errors.empty?
              puts "Import complete"
            else
              puts "Problems were detected during the execution phase"
              puts
              puts errors.each { |error| error.gsub(/<br\/>/, "\n") } << "\n"
              puts
              puts "Import failed"
            end
          end
        end
      end
    end

    desc "Imports only the puppet environments from SmartProxy source."
    task :environments_only, [:batch] => :environment do |t, args|
      User.as_anonymous_admin do
        args.batch = args.batch == "true"
        puts " ================================================================ "
        puts "Import starts: #{Time.now.strftime('%Y-%m-%d %H:%M:%S %Z')}"

        proxies = SmartProxy.with_features("Puppet")
        if proxies.empty?
          puts "ERROR: We did not find at least one configured Smart Proxy with the Puppet feature"
          exit 1
        end
        if ENV["proxy"]
          proxy = proxies.select {|p| p.name == ENV["proxy"]}.first
          unless proxy.is_a?(SmartProxy)
            puts "Smart Proxies #{ENV['proxy']} was not found, aborting"
            exit 1
          end
        end
        proxy ||= proxies.first
        # Evaluate any changes that exist between the database of environments and the on-disk puppet installation
        begin
          puts "Importing environments" unless args.batch
          importer = PuppetClassImporter.new({ :url => proxy.url })
          puts "New environments: #{importer.new_environments.join(', ')} "
          puts "Old environments: #{importer.old_environments.join(', ')} "
          importer.new_environments.each { |new_environment| Environment.create!(:name => new_environment) }
          importer.old_environments.each { |old_environment| Environment.find_by_name(old_environment).destroy }
        rescue => e
          puts "Problems were detected during the evaluation phase"
          puts
          puts e.message.gsub(/<br\/>/, "\n") + "\n"
          puts
          puts "Please fix these issues and try again"
          exit 1
        end
        puts "Import ends: #{Time.now.strftime('%Y-%m-%d %H:%M:%S %Z')}"
        puts " ================================================================ "
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
