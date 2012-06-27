# Author: Roberto Moral Denche (Telmo : telmox@gmail.com)
# Description: The tasks defined in this Rakefile will help you populate some of the
#    fields in Foreman with what is already present in your database from
#    StoragedConfig.
require 'rake/clean'
require 'yaml'

namespace :puppet do
  root    = "/"
  # Author: Paul Kelly (paul.ian.kelly@gogglemail.com)
  # Description: The tasks defined in this namespace populate a directory structure with rdocs for the
  # clases defined in puppet.
  namespace :rdoc do
    desc "
    Populates the rdoc tree with information about all the classes in your modules."
    task :generate => [:environment, :prepare] do
      Puppetclass.rdoc root
    end
    desc "
    Optionally creates a copy of the current puppet modules and sanitizes it.
    It should return the directory into which it has copied the cleaned modules"
    task :prepare => :environment do
      root = Puppetclass.prepare_rdoc root
    end
  end
  namespace :migrate do
    desc "Populates the host fields in Foreman based on your StoredConfig DB"
    task :populate_hosts => :environment do
      counter = 0
      Host.find_each do |host|
        if host.fact_values.size == 0
          $stdout.puts "#{host.hostname} has no facts, skipping"
          next
        end

        if host.populateFieldsFromFacts
          counter += 1
        else
          $stdout.puts "#{host.hostname}: #{host.errors.full_messages.join(", ")}"
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
        Host.importHostAndFacts File.read yaml
      end
    end
  end
  namespace :import do
    desc "Update puppet environments and classes. Optional batch flag triggers run with no prompting"
    task :puppet_classes,  [:batch, :envname] => :environment do | t, args |
      batch = args.batch == "true"
      # Evalute any changes that exist between the database of environments and puppetclasses and
      # the on-disk puppet installation
      begin
        puts "Evaluating possible changes to your installation" unless batch
        changes = Environment.importClasses args.envname
      rescue => e
        if batch
          Rails.logger.warn "Failed to refresh puppet classes: #{e}"
        else
          puts "Problems were detected during the evaluation phase"
          puts
          puts e.message.gsub(/<br\/>/, "\n") + "\n"
          puts
          puts "Please fix these issues and try again"
        end
        exit
      end

      if changes["new"].empty? and changes["obsolete"].empty?
        puts "No changes detected" unless batch
      else
        unless batch
          puts "Scheduled changes to your environment"
          puts "Create/update environments"
          for env, classes in changes["new"]
            print "%-15s: %s\n" % [env, classes.to_sentence]
          end
          puts "Delete environments"
          for env, classes in changes["obsolete"]
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
          changed = { :new => changes["new"], :obsolete => changes["obsolete"] }
          [:new, :obsolete].each { |kind| changed[kind].each_key { |k| changes[kind.to_s][k] = changes[kind.to_s][k].inspect } }
          errors = Environment.obsolete_and_new(changed)
        rescue => e
          errors = e.message + "\n" + e.backtrace.join("\n")
        end
        unless batch
          unless errors.empty?
            puts "Problems were detected during the execution phase"
            puts
            puts errors.each { |e| e.gsub(/<br\/>/, "\n") } << "\n"
            puts
            puts "Import failed"
          else
            puts "Import complete"
          end
        else
          Rails.logger.warn "Failed to refresh puppet classes: #{errors}"
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
        nodeinfo = YAML::load %x{#{script} #{host.name}}
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
