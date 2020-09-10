# TRANSLATORS: do not translate
desc <<~EOT
  When Foreman imports a new host by reading its facts it will create the host and
  set its model to a value based upon the facts. This can result in a multiplicity
  of similarly named models. These may be condensed donw into a few basic models
  by comparing the names against a list of model types and regular expressions that
  can be found in the config/model.mappings file.
EOT
namespace :models  do
  desc 'Reduce the many vendor supplied model names to a few sensible model definitions'
  task :consolidate, [:dryrun] => :environment do |t, args|
    dryrun = args.dryrun
    # Give ourselves permission to edit stuff
    User.current = User.anonymous_admin

    map_file = "config/model.mappings"
    if File.exist? map_file
      mappings = YAML.load_file map_file
      # Turn off any remote operations that may be called if we modify a host
      if SETTINGS[:unattended]
        puts "Please turn off unattended mode in config/settings.yaml before running this rake task."
        exit(-1)
      end
      names = mappings.map { |m| m["name"] }
      if names.count != names.uniq.count
        puts "There are duplicate entries in the the mapping file: " + (names - names.uniq).to_sentence
        exit(-1)
      end
      consolidate mappings, dryrun
    else
      puts "Unable to find #{map_file}. Please copy this from config/model.mappings.sample or download a newer version from theforeman.org."
    end
  end
end

def consolidate(mappings, dryrun)
  original_models = Model.count
  mapped = []
  mappings.each do |mapping|
    unless (rex = mapping.delete("rex"))
      puts "No regular expression found for #{mapping['name']}"
      next
    end
    unless mapping.has_key?("name") && mapping.has_key?("vendor_class") && mapping.has_key?("info") && mapping.has_key?("hardware_model")
      puts "There is a problem with the entry with regular expression #{rex}"
      next
    end
    matcher = %r{#{rex}}
    if (model = Model.find_by_name(mapping["name"]))
      puts "Using existing model for #{mapping['name']}"
      model.update! mapping unless dryrun
    elsif (model = Model.new(mapping))
      puts "Creating new model #{mapping['name']}"
    end
    Model.all.each do |original|
      if original.name =~ matcher
        puts "Mapping #{original.name} to #{mapping['name']}"
        mapped << original
        # Validate before we do block assignments
        valid_hosts = []
        original.hosts.each do |host|
          if host.valid?
            valid_hosts << host
          else
            puts "#{host.name}: #{host.errors.full_messages.to_sentence}"
          end
        end
        unless dryrun
          model.hosts << valid_hosts
          model.save(:validate => false)
          if model.errors.empty?
            original.delete if original.hosts.count == 0
          else
            puts "#{model.name} has these errors:" + model.errors.full_messages.to_sentence
          end
        end
      end
    end
  end
  puts "Models that were not recognized and converted: " + (Model.all - mapped).map(&:name).to_sentence
  final_models = Model.count
  puts "Condensed #{original_models} models down into #{final_models}" unless original_models == final_models
end
